//
//  PoseFeedFilterViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import Foundation
import RxSwift
import RxRelay

final class PoseFeedFilterViewModel {
    weak var coordinator: PoseFeedCoordinator?
    private var posefeedFilterUseCase: PoseFeedFilterUseCase
    
    init(coordinator: PoseFeedCoordinator?, posefeedFilterUseCase: PoseFeedFilterUseCase) {
        self.coordinator = coordinator
        self.posefeedFilterUseCase = posefeedFilterUseCase
    }
    
    struct Input {
        let filterTagSelectedEvent: Observable<PoseFeedFilterCellViewModel>
        let filterResetButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
        let selectedPeopleCount = PublishRelay<Int>()
        let selectedFrameCount = PublishRelay<Int>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        self.posefeedFilterUseCase.tagItems
            .subscribe(onNext: {
                output.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedFilterUseCase.peopleCount
            .subscribe(onNext: {
                output.selectedPeopleCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedFilterUseCase.frameCount
            .subscribe(onNext: {
                output.selectedFrameCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.filterTagSelectedEvent
            .subscribe(onNext: { [weak self] in
                self?.posefeedFilterUseCase.selectItem(title: $0.title.value)
            })
            .disposed(by: disposeBag)
        
        input.filterResetButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _) -> Observable<Bool> in
                guard let coordinator = owner.coordinator else { return Observable<Bool>.empty() }
                return coordinator.presentTagResetConfirmModal(disposeBag: disposeBag)
            }
            .subscribe(onNext: { [weak self] in
                if $0 {
                    self?.posefeedFilterUseCase.resetAllTags()
                } else {
                    return
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
