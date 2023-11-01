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
        let tagSelectCanceled: Observable<Void>
        let isPresenting: Observable<Bool>
        let resetButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let tagItems: Driver<[PoseFeedFilterCellViewModel]>
        let headCountTag: Driver<Int>
        let frameCountTag: Driver<Int>
        let registeredTags: Driver<[FilterTags]>
    }
    
    func transform(input: Input) -> Output {
        
        let tags = FilterTags.getAllFilterTags()
        let headCountTagIndex = BehaviorRelay<Int>(value: 0)
        let frameCountTagIndex = BehaviorRelay<Int>(value: 0)
        let registeredTags = BehaviorRelay<[FilterTags]>(value: [])
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
        let initialValue = BehaviorRelay<(Int, Int, [FilterTags])>(value: (0, 0, []))
        
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
        
        /// present 이후 데이터 초기값 불러오기
        input.isPresenting
            .flatMapLatest { isPresenting -> Observable<(Int, Int, [FilterTags])> in
                if isPresenting {
                    return Observable<(Int, Int, [FilterTags])>.just((headCountTagIndex.value, frameCountTagIndex.value, registeredTags.value))
                } else {
                    return Observable<(Int, Int, [FilterTags])>.empty()
                }
            }
            .subscribe(onNext: {
                initialValue.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 취소버튼 탭 이후 초기값으로 재초기화
        input.tagSelectCanceled
            .subscribe(onNext: {
                headCountTagIndex.accept(initialValue.value.0)
                frameCountTagIndex.accept(initialValue.value.1)
                registeredTags.accept(initialValue.value.2)
            })
            .disposed(by: disposeBag)
        
        /// 필터 초기화
        input.resetButtonTapped
            .subscribe(onNext: {
                headCountTagIndex.accept(0)
                frameCountTagIndex.accept(0)
                tagItems.accept(tags.map {
                    PoseFeedFilterCellViewModel(title: $0.rawValue)
                })
            })
            .disposed(by: disposeBag)
        
        tagItems.accept(tags.map {
            PoseFeedFilterCellViewModel(title: $0.rawValue)
        })
        
        return Output(tagItems: tagItems.asDriver(), headCountTag: headCountTagIndex.asDriver(), frameCountTag: frameCountTagIndex.asDriver(), registeredTags: registeredTags.asDriver())
    }
}
