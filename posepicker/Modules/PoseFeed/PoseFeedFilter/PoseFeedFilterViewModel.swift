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
    
    enum DismissState {
        case normal
        case save
    }
    
    struct Input {
        let headCountSelection: Observable<Int>
        let frameCountSelection: Observable<Int>
        let tagSelection: Observable<PoseFeedFilterCellViewModel>
        let registeredSubTag: BehaviorRelay<String?>
        let tagSelectCanceled: Observable<Void>
        let isPresenting: Observable<Bool>
        let resetButtonTapped: ControlEvent<Void>
        let dismissState: Observable<DismissState>
        let viewWillDisappearTrigger: Observable<Void>
        
        let countTagRemoveTrigger: Observable<PoseFeedViewModel.CountTagType>
        let filterTagRemoveTrigger: Observable<FilterTags>
        let subTagRemoveTrigger: Observable<Void>
        
        let detailViewDismissTrigger: Observable<Void>
        let filteredTagAfterDismiss: Observable<FilterTags?>
    }
    
    struct Output {
        let tagItems: Driver<[PoseFeedFilterCellViewModel]>
        let headCountTag: Driver<Int>
        let frameCountTag: Driver<Int>
        let registeredTags: Driver<[FilterTags]>
        let registeredSubTag: Driver<String?>
    }
    
    func transform(input: Input) -> Output {
        let headCountTagIndex = BehaviorRelay<Int>(value: 0)
        let frameCountTagIndex = BehaviorRelay<Int>(value: 0)
        let subTag = BehaviorRelay<String?>(value: nil)
        
        let registeredTags = BehaviorRelay<[FilterTags]>(value: [])
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
        let initialValue = BehaviorRelay<(Int, Int, [FilterTags], String?)>(value: (0, 0, [], nil))
        
        /// 초기 태그 아이템 세팅
        tagItems.accept(FilterTags.getAllFilterTags().map {
            PoseFeedFilterCellViewModel(title: $0.rawValue)
        })
        
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
        
        /// 서브태그 전달
        input.registeredSubTag
            .subscribe(onNext: {
                subTag.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// present 이후 데이터 초기값 불러오기
        input.isPresenting
            .flatMapLatest { isPresenting -> Observable<(Int, Int, [FilterTags], String?)> in
                if isPresenting {
                    return Observable.just((headCountTagIndex.value, frameCountTagIndex.value, registeredTags.value, subTag.value))
                } else {
                    return Observable<(Int, Int, [FilterTags], String?)>.empty()
                }
            }
            .subscribe(onNext: {
                initialValue.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 취소버튼 탭 이후 초기값으로 재초기화
        input.tagSelectCanceled
            .subscribe(onNext: {
                let tags = FilterTags.getAllFilterTags()
                
                headCountTagIndex.accept(initialValue.value.0)
                frameCountTagIndex.accept(initialValue.value.1)
                registeredTags.accept(initialValue.value.2) // 포즈피드 루트뷰 태그 리스트
                subTag.accept(initialValue.value.3)
                
                let initialTags = tags.filter {
                    registeredTags.value.contains($0)
                }
                tagItems.accept(tags.map {
                    let vm = PoseFeedFilterCellViewModel(title: $0.rawValue)
                    if initialTags.contains($0) {
                        vm.isSelected.accept(true)
                    }
                    return vm
                })
            })
            .disposed(by: disposeBag)
        
        /// 상세뷰 dismiss 이후 컬렉션뷰 아이템 셀렉팅
        input.filteredTagAfterDismiss
            .compactMap { $0 }
            .subscribe(onNext: { tag in
                let tags = FilterTags.getAllFilterTags()
                
                subTag.accept(nil) // 서브태그는 삭제
                registeredTags.accept([tag])
                
                tagItems.accept(tags.map {
                    let viewModel = PoseFeedFilterCellViewModel(title: $0.rawValue)
                    if tag.rawValue == $0.rawValue { viewModel.isSelected.accept(true) }
                    return viewModel
                })
            })
            .disposed(by: disposeBag)
        
        /// 필터 초기화
        input.resetButtonTapped
            .subscribe(onNext: {
                let tags = FilterTags.getAllFilterTags()
                
                headCountTagIndex.accept(0)
                frameCountTagIndex.accept(0)
                registeredTags.accept([])
                subTag.accept(nil)
                
                tagItems.accept(tags.map {
                    PoseFeedFilterCellViewModel(title: $0.rawValue)
                })
            })
            .disposed(by: disposeBag)
        
        /// 뷰 dismiss
        /// 데이터 저장하지 않고 dismiss하면 모달 올라올때 세팅되어 있던 초기값으로 다시 수정하는 로직
        Observable.combineLatest(input.dismissState, input.viewWillDisappearTrigger)
            .subscribe(onNext: { (dismissState, _) in
                let tags = FilterTags.getAllFilterTags()
                
                switch dismissState {
                case .normal:
                    headCountTagIndex.accept(initialValue.value.0)
                    frameCountTagIndex.accept(initialValue.value.1)
                    registeredTags.accept(initialValue.value.2)
                    subTag.accept(initialValue.value.3)
                    
                    let initialTags = tags.filter {
                        registeredTags.value.contains($0)
                    }
                    tagItems.accept(tags.map {
                        let vm = PoseFeedFilterCellViewModel(title: $0.rawValue)
                        if initialTags.contains($0) {
                            vm.isSelected.accept(true)
                        }
                        return vm
                    })
                case .save:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        /// 인원수 & 프레임 수 삭제 트리거
        input.countTagRemoveTrigger
            .subscribe(onNext: {
                switch $0 {
                case .head:
                    headCountTagIndex.accept(0)
                case .frame:
                    frameCountTagIndex.accept(0)
                }
            })
            .disposed(by: disposeBag)
        
        /// 일반태그 삭제 트리거
        input.filterTagRemoveTrigger
            .subscribe(onNext: {
                var tagValue = registeredTags.value
                guard let removeIndex = tagValue.firstIndex(of: $0) else { return }
                tagValue.remove(at: removeIndex)
                registeredTags.accept(tagValue)
                
                let viewModels = tagItems.value
                viewModels[removeIndex].isSelected.accept(false)
                tagItems.accept(viewModels)
            })
            .disposed(by: disposeBag)
        
        /// 서브태그 삭제 트리거
        input.subTagRemoveTrigger
            .subscribe(onNext: {
                subTag.accept(nil)
            })
            .disposed(by: disposeBag)
        
        /// 디테일 뷰 dismiss시 셀렉션 태그 제외하고 모든 태그정보 초기화
        input.detailViewDismissTrigger
            .subscribe(onNext: {
                let tags = FilterTags.getAllFilterTags()
                
                headCountTagIndex.accept(0)
                frameCountTagIndex.accept(0)
                registeredTags.accept([])
                subTag.accept(nil)
                tagItems.accept(tags.map {
                    PoseFeedFilterCellViewModel(title: $0.rawValue)
                })
            })
            .disposed(by: disposeBag)
        
        return Output(tagItems: tagItems.asDriver(), headCountTag: headCountTagIndex.asDriver(), frameCountTag: frameCountTagIndex.asDriver(), registeredTags: registeredTags.asDriver(), registeredSubTag: subTag.asDriver())
    }
}
