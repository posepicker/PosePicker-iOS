//
//  PoseFeedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import Kingfisher

class PoseFeedViewModel: ViewModelType {
    
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    var sizes = BehaviorRelay<[CGSize]>(value: [])
    var recommendedContentsSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var isLoading = false
    var currentPage = -1
    var isLast = false
    
    /// 포즈피드 컬렉션뷰 datasource 정의
    let dataSource = RxCollectionViewSectionedReloadDataSource<PoseSection>(configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PoseFeedPhotoCell.identifier, for: indexPath) as? PoseFeedPhotoCell else { return UICollectionViewCell() }
        cell.bind(to: item)
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedEmptyView.identifier, for: indexPath) as! PoseFeedEmptyView
            return header
        } else if indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedHeader.identifier, for: indexPath) as! PoseFeedHeader
            let title = dataSource.sectionModels[indexPath.section].header
            header.configureHeader(with: title)
            return header
        } else { return UICollectionReusableView() }
    })
    
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
        let viewDidLoadTrigger: Observable<Void>
        let viewDidDisappearTrigger: Observable<Void>
        let viewDidAppearTrigger: Observable<Void>
        let nextPageRequestTrigger: Observable<Void>
    }
    
    struct Output {
        let presentModal: Driver<Void>
        let filterTagItems: Driver<[RegisteredFilterCellViewModel]>
        let deleteTargetFilterTag: Driver<FilterTags?>
        let deleteTargetCountTag: Driver<CountTagType?>
        let sections: Observable<[PoseSection]>
    }
    
    // MARK: - 이미지 하나씩 바인딩하지 말고 모두 다 받고 진행
    func transform(input: Input) -> Output {
        let tagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
        let deleteTargetFilterTag = BehaviorRelay<FilterTags?>(value: nil)
        let deleteTargetCountTag = BehaviorRelay<CountTagType?>(value: nil)
        
        let retrievedCacheImage = BehaviorRelay<[UIImage?]>(value: [])
        let recommendedCacheImage = BehaviorRelay<[UIImage?]>(value: [])
        
        let downloadCountForPageSize = BehaviorRelay<Int>(value: 0)
        let recommendedCountForPageSize = BehaviorRelay<Int>(value: 0)
        
        let queryParameters = BehaviorRelay<[String]>(value: [])
        let pageSize = BehaviorRelay<Int>(value: 10)
        let currentPage = BehaviorRelay<Page?>(value: nil)
        let sections = BehaviorRelay<[PoseSection]>(value: [PoseSection(header: "", items: []), PoseSection(header: "이런 포즈는 어때요?", items: [])])
        let recommendedContents = BehaviorRelay<RecommendedContents?>(value: nil)

        
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
        input.viewDidLoadTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                return self.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: 0, pageSize: 10)).asObservable()
            }
            .subscribe(onNext: { [unowned self] posefeed in
                currentPage.accept(posefeed.pageable)
                pageSize.accept(posefeed.content.count) // 데이터 로드 대기 갯수
                posefeed.content.forEach { [weak self] pose in
                    self?.retrieveCacheImage(cacheKey: pose.poseInfo.imageKey, cacheImageRelayObject: retrievedCacheImage, downloadCount: downloadCountForPageSize)
                }
            })
            .disposed(by: disposeBag)
        
        /// 쿼리 파라미터 세팅 이후 이미지 세팅
        queryParameters
            .flatMapLatest { [unowned self] tags -> Observable<FilteredPose> in
                currentPage.accept(nil) // 필터 세팅 후 기존 페이지네이션 정보 초기화
                self.resetBinding(sectionRelayObject: sections, filteredCacheImage: retrievedCacheImage, recommendedCacheImage: recommendedCacheImage)
                recommendedContents.accept(nil)
                if tags.count < 2 {
                    return Observable<FilteredPose>.empty()
                }
                var filterTags: [String] = []
                if tags.count > 2 {
                    filterTags = Array(tags[2..<tags.count])
                }
                return self.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: tags[0], frameCount: tags[1], filterTags: filterTags, pageNumber: 0)).asObservable()
            }
            .map { filteredContents -> [PosePick] in
                recommendedContents.accept(filteredContents.recommendedContents)
                return filteredContents.filteredContents.content
            }
            .subscribe(onNext: { [unowned self] filteredContent in
                retrievedCacheImage.accept([])
                self.sizes.accept([])
                pageSize.accept(filteredContent.count)
                
                filteredContent.forEach { [weak self] pose in
                    self?.retrieveCacheImage(cacheKey: pose.poseInfo.imageKey, cacheImageRelayObject: retrievedCacheImage, downloadCount: downloadCountForPageSize)
                }
            })
            .disposed(by: disposeBag)
        
        
        /// 무한스크롤 로직
        /// 1. queryParameters가 비어있는데 스크롤이 트리거되면 필터 없이 무한스크롤 요청
        input.nextPageRequestTrigger
            .flatMapLatest { queryParameters }
            .flatMapLatest { [unowned self] tags -> Observable<PoseFeed> in
                if tags.isEmpty {
                    self.beginLoading()
                    return self.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: self.currentPage + 1, pageSize: 8)).asObservable()
                } else {
                    return Observable<PoseFeed>.empty()
                }
            }
            .subscribe(onNext: { [unowned self] posefeed in
                currentPage.accept(posefeed.pageable)
                self.isLast = posefeed.last
                pageSize.accept(posefeed.content.count) // 데이터 로드 대기 갯수
                posefeed.content.forEach { [weak self] pose in
                    self?.retrieveCacheImage(cacheKey: pose.poseInfo.imageKey, cacheImageRelayObject: retrievedCacheImage, downloadCount: downloadCountForPageSize)
                }
            })
            .disposed(by: disposeBag)
        
        /// 2. queryParameters 있는채로 스크롤 트리거 - 필터 API 요청
        input.nextPageRequestTrigger
            .flatMapLatest { queryParameters }
            .flatMapLatest { [unowned self] tags -> Observable<FilteredPose> in
                if tags.isEmpty {
                    return Observable<FilteredPose>.empty()
                } else {
                    self.beginLoading()
                    if tags.count < 2 {
                        return Observable<FilteredPose>.empty()
                    }
                    var filterTags: [String] = []
                    if tags.count > 2 {
                        filterTags = Array(tags[2..<tags.count])
                    }
                    return self.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: tags[0], frameCount: tags[1], filterTags: filterTags, pageNumber: self.currentPage + 1)).asObservable()
                }
            }
            .map { filteredContents -> [PosePick] in
                currentPage.accept(filteredContents.filteredContents.pageable)
                self.isLast = filteredContents.filteredContents.last
                return filteredContents.filteredContents.content
            }
            .subscribe(onNext: { [unowned self] filteredContent in
                pageSize.accept(filteredContent.count)
                
                filteredContent.forEach { [weak self] pose in
                    self?.retrieveCacheImage(cacheKey: pose.poseInfo.imageKey, cacheImageRelayObject: retrievedCacheImage, downloadCount: downloadCountForPageSize)
                }
            })
            .disposed(by: disposeBag)
        
        /// 3. 페이지 세팅 이후
        currentPage
            .subscribe(onNext: { [unowned self] in
                guard let page = $0 else {
                    self.currentPage = 0
                    self.isLast = false
                    return
                }
                self.currentPage = page.pageNumber
            })
            .disposed(by: disposeBag)
        
        /// 추천 컨텐츠 바인딩 로직
        recommendedContents
            .compactMap { $0 }
            .subscribe(onNext: { recommended in
                let posepick = recommended.content
                posepick.forEach { [weak self] pose in
                    // 추천이미지 섹션 item에 객체 저장
                    self?.retrieveCacheImage(cacheKey: pose.poseInfo.imageKey, cacheImageRelayObject: recommendedCacheImage, downloadCount: recommendedCountForPageSize, isRecommendedContents: true)
                }
            })
            .disposed(by: disposeBag)
        
        /// 필터링 이미지 로딩
        Observable.combineLatest(retrievedCacheImage, downloadCountForPageSize, pageSize)
            .subscribe(onNext: { [unowned self] images, downloadCount, pageSize in
                if downloadCount < pageSize {
                    return
                }
                self.endLoading()
                
                let viewModels = images.map { image in
                    PoseFeedPhotoCellViewModel(image: image)
                }
                
                var filteredSectionItems = sections.value[0].items
                filteredSectionItems = viewModels
                let recommendedSection = sections.value[1]
                
                sections.accept([PoseSection(header: "", items: filteredSectionItems), recommendedSection])
            })
            .disposed(by: disposeBag)
        
        /// 추천 이미지 로딩
        Observable.combineLatest(recommendedCacheImage, recommendedCountForPageSize, pageSize)
            .subscribe(onNext: { [unowned self] images, downloadCount, pageSize in
                if downloadCount < pageSize {
                    return
                }
                
                self.endLoading()
                
                let viewModels = images.map { image in
                    PoseFeedPhotoCellViewModel(image: image)
                }
                
                var recommendedSectionItems = sections.value[1].items
                recommendedSectionItems = viewModels
                let filteredSection = sections.value[0]
                
                sections.accept([filteredSection, PoseSection(header: "이런 포즈는 어때요?", items: recommendedSectionItems)])
            })
            .disposed(by: disposeBag)
        
        return Output(presentModal: input.filterButtonTapped.asDriver(), filterTagItems: tagItems.asDriver(), deleteTargetFilterTag: deleteTargetFilterTag.asDriver(), deleteTargetCountTag: deleteTargetCountTag.asDriver(), sections: sections.asObservable())
    }
    
    /// 디자인 수치 기준으로 이미지 리사이징
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
    
    /// 로딩상태 업데이트
    func beginLoading() {
        self.isLoading = true
    }
    
    func endLoading() {
        self.isLoading = false
    }
    
    /// 이미지 바인딩 리셋
    func resetBinding(sectionRelayObject: BehaviorRelay<[PoseSection]>, filteredCacheImage: BehaviorRelay<[UIImage?]>, recommendedCacheImage: BehaviorRelay<[UIImage?]>) {
        let defaultValue = [PoseSection(header: "", items: []), PoseSection(header: "이런 포즈는 어때요?", items: [])]
        sectionRelayObject.accept(defaultValue)
        filteredCacheImage.accept([])
        recommendedCacheImage.accept([])
    }
    
    /// call by reference 활용 - 캐시처리 로직 함수화
    func retrieveCacheImage(cacheKey: String, cacheImageRelayObject: BehaviorRelay<[UIImage?]>, downloadCount: BehaviorRelay<Int>, isRecommendedContents: Bool = false) {
        ImageCache.default.retrieveImage(forKey: cacheKey, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                    cacheImageRelayObject.accept(cacheImageRelayObject.value + [newSizeImage])
                    isRecommendedContents ? self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size]) : self.sizes.accept(self.sizes.value + [newSizeImage.size])
                    downloadCount.accept(downloadCount.value + 1)
                } else {
                    guard let url = URL(string: cacheKey) else { return }
                    KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                        switch downloadResult {
                        case .success(let downloadImage):
                            let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                            cacheImageRelayObject.accept(cacheImageRelayObject.value + [newSizeImage])
                            isRecommendedContents ? self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size]) : self.sizes.accept(self.sizes.value + [newSizeImage.size])
                            downloadCount.accept(downloadCount.value + 1)
                        case .failure:
                            return
                        }
                    }
                }
            case .failure:
                cacheImageRelayObject.accept(cacheImageRelayObject.value + [nil])
            }
        }
    }
}
