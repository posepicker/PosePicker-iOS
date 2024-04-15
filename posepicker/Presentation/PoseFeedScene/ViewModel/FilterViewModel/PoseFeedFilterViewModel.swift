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
    private let currentTags: [String]
    
    init(coordinator: PoseFeedCoordinator?, posefeedFilterUseCase: PoseFeedFilterUseCase, currentTags: [String]) {
        self.coordinator = coordinator
        self.posefeedFilterUseCase = posefeedFilterUseCase
        self.currentTags = currentTags
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let peopleCountTagSelectedEvent: Observable<Int>
        let frameCountTagSelectedEvent: Observable<Int>
        let filterTagSelectedEvent: Observable<PoseFeedFilterCellViewModel>
        let filterResetButtonTapEvent: Observable<Void>
        let filterTagSaveButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let peopleCountIndex = PublishRelay<Int>()
        let frameCountIndex = PublishRelay<Int>()
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                if let index = PeopleCountTags.getIndexFromPeopleCountString(countString: owner.currentTags[0]) {
                    output.peopleCountIndex.accept(index)
                }
                
                if let index = FrameCountTags.getIndexFromFrameCountString(countString: owner.currentTags[1]) {
                    output.frameCountIndex.accept(index)
                }
                
                for tag in owner.currentTags[2...] {
                    owner.posefeedFilterUseCase.selectItem(title: tag)
                }
            })
            .disposed(by: disposeBag)
        
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
                    output.peopleCountIndex.accept(0)
                    output.frameCountIndex.accept(0)
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
