//
//  PoseTalkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

// TODO: - 코디네이터로 수퍼뷰 높이값 확인 필요 / 툴팁 위치 지정하는 로직 구현해야됨
class PoseTalkViewModel {
    weak var coordinator: PoseTalkCoordinator?
    private let posetalkUseCase: PoseTalkUseCase
    
    init(coordinator: PoseTalkCoordinator?, posetalkUseCase: PoseTalkUseCase) {
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
        let tooltipButtonTapEvent: Observable<Void>
        let viewDidLoadEvent: Observable<Void>
        let viewDidDisappearEvent: Observable<Void>
    }
    
    struct Output {
        let animate = PublishSubject<Void>()
        let poseWord = PublishRelay<String>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        let maxRetryValue = BehaviorRelay<Int>(value: 0)
        
        self.configureInput(input, disposeBag: disposeBag)
        
        input.tooltipButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.toggleTooltip()
            })
            .disposed(by: disposeBag)
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.addTooltip()
            })
            .disposed(by: disposeBag)
        
        input.viewDidDisappearEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.removeTooltip()
            })
            .disposed(by: disposeBag)
        
        input.poseTalkButtonTapped
            .subscribe(onNext: {
                maxRetryValue.accept(1)
                output.animate.onNext(())
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(self.posetalkUseCase.poseWord, input.isAnimating, self.posetalkUseCase.isLoading)
            .subscribe(onNext: { poseWord, animating, isLoading in
                guard let poseWord = poseWord,
                      !isLoading else {
                    if !animating && maxRetryValue.value < 5 {
                        maxRetryValue.accept(maxRetryValue.value + 1)
                        output.animate.onNext(())
                    }
                    return
                }
                
                if !animating {
                    maxRetryValue.accept(1)
                    output.poseWord.accept(poseWord)
                }
            })
            .disposed(by: disposeBag)
        
        return output
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
}
