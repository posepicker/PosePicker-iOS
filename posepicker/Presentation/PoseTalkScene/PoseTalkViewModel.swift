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
    
    struct Input {
        let poseTalkButtonTapped: ControlEvent<Void>
        let isAnimating: Observable<Bool>
    }
    
    struct Output {
        let animate = Driver<Void>.empty()
        let poseWord = PublishRelay<String>()
        let isLoading = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input) -> Output {
        let poseWord = BehaviorRelay<String>(value: "제시어에 맞춰\n포즈를 취해요!")
        let isLoading = BehaviorRelay<Bool>(value: false)
        
        /// 애니메이션 + 네트워크 관련 로직 추가를 고려한 설계
        input.isAnimating
            .subscribe(onNext: {
                isLoading.accept($0)
            })
            .disposed(by: disposeBag)
        self.configureInput(input, disposeBag: disposeBag)
        return createOutput(from: input, disposeBag: disposeBag)
    }
    
    /// configureInput: 인풋 이벤트를 기반으로 유스케이스 -> 레파지토리를 거쳐 데이터를 저장해둔다.
    /// 유스케이스에는 레파지토리의 데이터 요청 내부 동작을 가린채 정제가 완료된 최종 데이터만 저장된다.
    /// 아웃풋에서는 저장된 유스케이스의 데이터를 바인딩만 해주면 끝
    private func configureInput(_ input: Input, disposeBag: DisposeBag) {
        input.poseTalkButtonTapped
            .subscribe(onNext: { [weak self] in
                print("TAPPP")
                self?.posetalkUseCase.fetchPoseTalk()
            })
            .disposed(by: disposeBag)
    }
    
    /// createOutput: configureInput 함수 내에서 유스케이스에 모든 데이터 정제가 끝날 수도 있지만
    /// cocoa 이벤트를 기반으로 새롭게 아웃풋에 정제가 필요한 경우도 존재함
    private func createOutput(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()

        self.posetalkUseCase
            .poseWord
            .bind(to: output.poseWord)
            .disposed(by: disposeBag)
        
        return output
    }
}
