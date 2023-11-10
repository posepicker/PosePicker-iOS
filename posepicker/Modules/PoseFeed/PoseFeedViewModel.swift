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
    var sizes = BehaviorRelay<[CGSize]>(value: [])
    
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
        let viewDidDisappearTrigger: Observable<Void>
    }
    
    struct Output {
        let presentModal: Driver<Void>
        let filterTagItems: Driver<[RegisteredFilterCellViewModel]>
        let deleteTargetFilterTag: Driver<FilterTags?>
        let deleteTargetCountTag: Driver<CountTagType?>
        let photoCellItems: Driver<[PoseFeedPhotoCellViewModel]>
    }
    // MARK: - 이미지 하나씩 바인딩하지 말고 모두 다 받고 진행
    func transform(input: Input) -> Output {
        let tagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
        let deleteTargetFilterTag = BehaviorRelay<FilterTags?>(value: nil)
        let deleteTargetCountTag = BehaviorRelay<CountTagType?>(value: nil)
        let photoCellItems = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let retrievedCacheImage = BehaviorRelay<[UIImage?]>(value: [])
        let downloadCountForPageSize = BehaviorRelay<Int>(value: 0)
        let queryParameters = BehaviorRelay<[String]>(value: [])
        let pageSize = BehaviorRelay<Int>(value: 10)
        
        
        /// 필터 등록 완료 + 필터 모달이 Present 상태일때
        /// 인원 수 & 프레임 수 셀렉션으로부터 데이터 추출
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
                queryParameters.accept(tags)
                tagItems.accept(tags.compactMap { tagName in
                    if tagName == "전체" { return nil }
                    return RegisteredFilterCellViewModel(title: tagName)
                })
            })
            .disposed(by: disposeBag)
        
        /// 포즈피드 태그 modelSelected 이후 태그 삭제를 위한 단위 추출 (1컷, 1인 등)
        /// 필터태그는 그냥 삭제
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
        
        /// viewDidAppear 이후 데이터 요청
        input.viewDidAppearTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                self.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: 0, pageSize: 10)).asObservable()
            }
            .subscribe(onNext: { [unowned self] posefeed in
                pageSize.accept(posefeed.content.count) // 데이터 로드 대기 갯수
                
                posefeed.content.forEach { pose in
                    ImageCache.default.retrieveImage(forKey: pose.poseInfo.imageKey, options: nil) { result in
                        switch result {
                        case .success(let value):
                            if let image = value.image {
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                                retrievedCacheImage.accept(retrievedCacheImage.value + [newSizeImage])
                                self.sizes.accept(self.sizes.value + [newSizeImage.size])
                                downloadCountForPageSize.accept(downloadCountForPageSize.value + 1)
                            } else {
                                guard let url = URL(string: pose.poseInfo.imageKey) else { return }
                                KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                                    switch downloadResult {
                                    case .success(let downloadedImage):
                                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadedImage.image)
                                        retrievedCacheImage.accept(retrievedCacheImage.value + [newSizeImage])
                                        self.sizes.accept(self.sizes.value + [newSizeImage.size])
                                        downloadCountForPageSize.accept(downloadCountForPageSize.value + 1)
                                    case .failure:
                                        return
                                    }
                                }
                            }
                            
                        case .failure:
                            retrievedCacheImage.accept(retrievedCacheImage.value + [nil])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        /// 쿼리 파라미터 세팅 이후 이미지 세팅
        queryParameters
            .flatMapLatest { [unowned self] tags -> Observable<FilteredPose> in
                if tags.count < 2 {
                    return Observable<FilteredPose>.empty()
                }
                var filterTags: [String] = []
                if tags.count > 2 {
                    filterTags = Array(tags[2..<tags.count])
                }
                return self.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: tags[0], frameCount: tags[1], filterTags: filterTags, pageNumber: 0)).asObservable()
            }
            .map { $0.filteredContents.content }
            .subscribe(onNext: { [unowned self] filteredContent in
                retrievedCacheImage.accept([])
                self.sizes.accept([])
                pageSize.accept(filteredContent.count)
                
                filteredContent.forEach { pose in
                    ImageCache.default.retrieveImage(forKey: pose.poseInfo.imageKey, options: nil) { result in
                        switch result {
                        case .success(let value):
                            if let image = value.image {
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                                retrievedCacheImage.accept(retrievedCacheImage.value + [newSizeImage])
                                self.sizes.accept(self.sizes.value + [newSizeImage.size])
                                downloadCountForPageSize.accept(downloadCountForPageSize.value + 1)
                            } else {
                                guard let url = URL(string: pose.poseInfo.imageKey) else { return }
                                KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                                    switch downloadResult {
                                    case .success(let downloadedImage):
                                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadedImage.image)
                                        retrievedCacheImage.accept(retrievedCacheImage.value + [newSizeImage])
                                        self.sizes.accept(self.sizes.value + [newSizeImage.size])
                                        downloadCountForPageSize.accept(downloadCountForPageSize.value + 1)
                                    case .failure:
                                        return
                                    }
                                }
                            }
                            
                        case .failure:
                            retrievedCacheImage.accept(retrievedCacheImage.value + [nil])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(retrievedCacheImage, downloadCountForPageSize, pageSize)
            .subscribe(onNext: { images, downloadCount, pageSize in
                if downloadCount < pageSize {
                    return
                }
                let viewModels = images.map { image in PoseFeedPhotoCellViewModel(image: image) }
                photoCellItems.accept(viewModels)
            })
            .disposed(by: disposeBag)
        
        return Output(presentModal: input.filterButtonTapped.asDriver(), filterTagItems: tagItems.asDriver(), deleteTargetFilterTag: deleteTargetFilterTag.asDriver(), deleteTargetCountTag: deleteTargetCountTag.asDriver(), photoCellItems: photoCellItems.asDriver())
    }
    
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let targetSize = CGSize(width: targetWidth, height: targetWidth * image.size.height / image.size.width)
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
}
