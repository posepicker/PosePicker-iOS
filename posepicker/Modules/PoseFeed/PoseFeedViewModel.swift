//
//  PoseFeedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class PoseFeedViewModel: ViewModelType {
    
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    
    enum CountTagType {
        case head
        case frame
    }
    
    struct Input {
        let filterButtonTapped: ControlEvent<Void>
        let tagItems: Observable<(String, String, [FilterTags])>
        let filterTagSelection: Observable<RegisteredFilterCellViewModel>
        let filterRegisterCompleted: ControlEvent<Void>
        let poseFeedFilterViewIsPresenting: Observable<Bool>
        let filterReset: ControlEvent<Void>
        let viewDidAppearTrigger: Observable<Void>
    }
    
    struct Output {
        let presentModal: Driver<Void>
        let filterTagItems: Driver<[RegisteredFilterCellViewModel]>
        let deleteTargetFilterTag: Driver<FilterTags?>
        let deleteTargetCountTag: Driver<CountTagType?>
        let photoCellItems: Driver<[PoseFeedPhotoCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let tagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
        let deleteTargetFilterTag = BehaviorRelay<FilterTags?>(value: nil)
        let deleteTargetCountTag = BehaviorRelay<CountTagType?>(value: nil)
        let photoCellItems = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let retrievedCacheImage = BehaviorRelay<[UIImage?]>(value: [])
        let urlsCount = BehaviorRelay<Int>(value: 0)
        
        input.filterRegisterCompleted
            .flatMapLatest { () -> Observable<Bool> in
                return input.poseFeedFilterViewIsPresenting
            }
            .flatMapLatest { isPresenting -> Observable<(String, String, [FilterTags])> in
                if isPresenting {
                    return Observable<(String, String, [FilterTags])>.empty()
                } else {
                    return input.tagItems
                }
            }
            .flatMapLatest { (headcount, frameCount, filterTags) -> Observable<[String]> in
                return BehaviorRelay<[String]>(value: [headcount, frameCount] + filterTags.map { $0.rawValue} ).asObservable()
            }
            .subscribe(onNext: { tags in
                tagItems.accept(tags.compactMap { tagName in
                    if tagName == "전체" { return nil }
                    return RegisteredFilterCellViewModel(title: tagName)
                })
            })
            .disposed(by: disposeBag)
        
        input.filterTagSelection
            .subscribe(onNext: {
                if let filterTag = FilterTags.getTagFromTitle(title: $0.title.value) {
                    deleteTargetFilterTag.accept(filterTag)
                } else if !$0.title.value.isEmpty { // 인원수 or 프레임 수 태그인 경우
                    let tagName = $0.title.value
                    let tagUnit = tagName[tagName.index(tagName.startIndex, offsetBy: 1)]
                    switch tagUnit {
                    case "컷":
                        deleteTargetCountTag.accept(.frame)
                    case "인":
                        deleteTargetCountTag.accept(.head)
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.viewDidAppearTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                self.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: 0, pageSize: 10)).asObservable()
            }
            .subscribe(onNext: { posefeed in
                urlsCount.accept(0)
                urlsCount.accept(posefeed.content.count)
                posefeed.content.forEach { pose in
                    ImageCache.default.retrieveImage(forKey: pose.poseInfo.imageKey, options: nil) { result in
                        switch result {
                        case .success(let value):
                            retrievedCacheImage.accept(retrievedCacheImage.value + [value.image])
                        case .failure:
                            retrievedCacheImage.accept(retrievedCacheImage.value + [nil])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        retrievedCacheImage
            .subscribe(onNext: { images in
                let viewModels = images.map { image in
                    PoseFeedPhotoCellViewModel(image: image)
                }
                photoCellItems.accept(viewModels)
            })
            .disposed(by: disposeBag)
        
        
        return Output(presentModal: input.filterButtonTapped.asDriver(), filterTagItems: tagItems.asDriver(), deleteTargetFilterTag: deleteTargetFilterTag.asDriver(), deleteTargetCountTag: deleteTargetCountTag.asDriver(), photoCellItems: photoCellItems.asDriver())
    }
}
