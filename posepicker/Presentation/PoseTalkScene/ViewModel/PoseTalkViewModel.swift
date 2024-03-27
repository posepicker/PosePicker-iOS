//
//  PoseTalkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class PoseTalkViewModel: ViewModelType {
    weak var coordinator: RootCoordinator?
    private let posetalkUseCase: PoseTalkUseCase
    
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    
    init(coordinator: RootCoordinator?, posetalkUseCase: PoseTalkUseCase) {
        self.coordinator = coordinator
        self.posetalkUseCase = posetalkUseCase
    }
    
    /// UI 통신 순서
    /// 1. 버튼을 누른다
    /// 2. 애니메이션을 한바퀴 돌린다 - 버튼 인풋에 대해 애니메이션을 뷰 컨트롤러에게 명령
    /// 3. 동시에 포즈톡 키워드를 요청한다
    /// 4. 애니메이션이 끝나면 단어를 화면에 표시한다
    /// 5. 데이터를 내보내는 시점 조절을 위해 컨트롤러로부터 애니메이션 종료 여부까지 전달받기
    struct Input {
        let poseTalkButtonTapped: ControlEvent<Void>
        let isAnimating: BehaviorRelay<Bool>
    }
    
    struct Output {
        let animate = PublishSubject<Void>()
        let poseWord = PublishRelay<String>()
        let isLoading = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input) -> Output {
        self.configureInput(input, disposeBag: disposeBag)
        return createOutput(from: input, disposeBag: disposeBag)
    }

    /// configureInput: 인풋 이벤트를 기반으로 유스케이스 -> 레파지토리를 거쳐 데이터를 저장해둔다.
    /// 유스케이스에는 레파지토리의 데이터 요청 내부 동작을 가린채 정제가 완료된 최종 데이터만 저장된다.
    /// 아웃풋에서는 저장된 유스케이스의 데이터를 바인딩만 해주면 끝
    private func configureInput(_ input: Input, disposeBag: DisposeBag) {
        input.poseTalkButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.posetalkUseCase.fetchPoseTalk()
            })
            .disposed(by: disposeBag)
    }
    
    /// createOutput: configureInput 함수 내에서 유스케이스에 모든 데이터 정제가 끝날 수도 있지만
    /// cocoa 이벤트를 기반으로 새롭게 아웃풋에 정제가 필요한 경우도 존재함
    private func createOutput(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.poseTalkButtonTapped
            .subscribe(onNext: {
                output.animate.onNext(())
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(self.posetalkUseCase.poseWord, input.isAnimating)
            .subscribe(onNext: { poseWord, animating in
                if !animating {
                    output.poseWord.accept(poseWord)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
