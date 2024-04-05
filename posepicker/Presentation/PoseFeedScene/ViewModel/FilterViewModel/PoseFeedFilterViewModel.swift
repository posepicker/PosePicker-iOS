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
        let peopleCountTagSelectedEvent: Observable<Int>
        let frameCountTagSelectedEvent: Observable<Int>
        let filterTagSelectedEvent: Observable<PoseFeedFilterCellViewModel>
        let filterResetButtonTapEvent: Observable<Void>
        let filterTagSaveButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        self.posefeedFilterUseCase.tagItems
            .subscribe(onNext: {
                output.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.peopleCountTagSelectedEvent
            .subscribe(onNext: { [weak self] in
                self?.posefeedFilterUseCase.selectPeopleCount(value: $0)
            })
            .disposed(by: disposeBag)
        
        input.frameCountTagSelectedEvent
            .subscribe(onNext: { [weak self] in
                self?.posefeedFilterUseCase.selectFrameCount(value: $0)
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
        
        input.filterTagSaveButtonTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let peopleCountTag = PeopleCountTags.getTagTitleFromIndex(index: self.posefeedFilterUseCase.peopleCount.value),
                      let frameCountTag = FrameCountTags.getTagTitleFromIndex(index: self.posefeedFilterUseCase.frameCount.value) else { return }
                var tags = [peopleCountTag, frameCountTag]
                tags += self.posefeedFilterUseCase.tagItems.value.filter { $0.isSelected.value }.map { $0.title.value }
                
                self.coordinator?.dismissFilterModal(registeredTags: tags)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
