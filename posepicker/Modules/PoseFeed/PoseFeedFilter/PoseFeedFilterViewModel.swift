//
//  PoseFeedFilterViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import Foundation
import RxCocoa
import RxSwift

class PoseFeedFilterViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let headCountSelection: Observable<Int>
        let frameCountSelection: Observable<Int>
        let tagSelection: Observable<PoseFeedFilterCellViewModel>
    }
    
    struct Output {
        let tagItems: Driver<[PoseFeedFilterCellViewModel]>
        let headCountTag: BehaviorRelay<Int>
        let frameCountTag: BehaviorRelay<Int>
        let registeredTags: BehaviorRelay<[FilterTags]>
    }
    
    func transform(input: Input) -> Output {
        
        let tags = FilterTags.getAllFilterTags()
        let headCountTagIndex = BehaviorRelay<Int>(value: 0)
        let frameCountTagIndex = BehaviorRelay<Int>(value: 0)
        let registeredTags = BehaviorRelay<[FilterTags]>(value: [])
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
        
        /// 인원 수 셀렉팅
        input.headCountSelection
            .subscribe(onNext: {
                headCountTagIndex.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 프레임 수 셀렉팅
        input.frameCountSelection
            .subscribe(onNext: {
                frameCountTagIndex.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 태그정보 셀렉팅
        input.tagSelection
            .subscribe(onNext: {
                $0.isSelected.accept(!$0.isSelected.value)

                /// 태그 셀렉팅에 따라 선택된 태그들 릴레이 객체에 업데이트
                if let selectedTag = FilterTags.getTagFromTitle(title: $0.title.value) {
                    if registeredTags.value.contains(selectedTag) {
                        var currentFilter = registeredTags.value
                        if let index = currentFilter.firstIndex(of: selectedTag) {
                            currentFilter.remove(at: index)
                        }
                        registeredTags.accept(currentFilter.sorted(by: {$0.getTagNumber() < $1.getTagNumber()}))
                    } else {
                        let newTags = registeredTags.value + [selectedTag]
                        registeredTags.accept(newTags.sorted(by: { $0.getTagNumber() < $1.getTagNumber() }))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        tagItems.accept(tags.map {
            PoseFeedFilterCellViewModel(title: $0.rawValue)
        })
        
        return Output(tagItems: tagItems.asDriver(), headCountTag: headCountTagIndex, frameCountTag: frameCountTagIndex, registeredTags: registeredTags)
    }
}
