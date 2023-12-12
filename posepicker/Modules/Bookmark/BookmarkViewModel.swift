//
//  BookmarkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import Kingfisher

class BookMarkViewModel: ViewModelType {
    
    var apiSession: APISession
    var disposeBag = DisposeBag()
    var imageDownloader: ImageDownloader
    
    var filteredContentSizes = BehaviorRelay<[CGSize]>(value: [])
    var recommendedContentsSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var currentPage = 0
    var isLast = false
    var isLoading = false
    
    /// 포즈피드 컬렉션뷰 datasource 정의
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<BookmarkSection>(configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkFeedCell.identifier, for: indexPath) as? BookmarkFeedCell else { return UICollectionViewCell() }
        
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkEmptyView.identifier, for: indexPath) as! BookmarkEmptyView
            return header
        } else { return UICollectionReusableView() }
    })
    
    init(apiSession: APISession = APISession(), imageDownloader: ImageDownloader = ImageDownloader.default) {
        self.apiSession = apiSession
        self.imageDownloader = imageDownloader
    }
    
    struct Input {
        var viewDidLoadTrigger: Observable<Void>
        var nextPageTrigger: Observable<Void>
    }
    
    struct Output {
        let sectionItems: Observable<[BookmarkSection]>
        let isEmpty: Driver<Bool?>
    }
    
    func transform(input: Input) -> Output {
        let isEmpty = BehaviorRelay<Bool?>(value: nil)
        let sectionItems = BehaviorRelay<[BookmarkSection]>(value: [BookmarkSection(header: "", items: [])])
        
        /// 1. 뷰 로드 이후 컬렉션뷰 셀 아이템 API 요청
        input.viewDidLoadTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                return apiSession.requestSingle(.retrieveBookmarkFeed(userId: 0, pageNumber: 0, pageSize: 8)).asObservable()
            }
            .map { $0.content }
            .flatMapLatest { [unowned self] posefeed -> Observable<[BookmarkFeedCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
            }
            .subscribe(onNext: {
                var items = sectionItems.value.first?.items ?? []
                items.append(contentsOf: $0)
                let newSection = BookmarkSection(header: "", items: items)
                
                sectionItems.accept([newSection])
                isEmpty.accept($0.isEmpty ? true : false)
            })
            .disposed(by: disposeBag)
        
        /// 2. 무한스크롤 다음 페이지 트리거
        input.nextPageTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                self.isLoading = true
                return apiSession.requestSingle(.retrieveBookmarkFeed(userId: 0, pageNumber: 0, pageSize: 8)).asObservable()
            }
            .map { [unowned self] in
                self.currentPage = $0.pageable.pageNumber
                self.isLast = $0.last
                self.isLoading = false
                return $0.content
            }
            .flatMapLatest { [unowned self] posefeed -> Observable<[BookmarkFeedCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
            }
            .subscribe(onNext: {
                var items = sectionItems.value.first?.items ?? []
                items.append(contentsOf: $0)
                let newSection = BookmarkSection(header: "", items: items)
                
                sectionItems.accept([newSection])
                isEmpty.accept(true)
            })
            .disposed(by: disposeBag)
        
        return Output(sectionItems: sectionItems.asObservable(), isEmpty: isEmpty.asDriver())
    }
    
    // MARK: - 킹피셔 이미지 캐싱 관련 함수들
    /// 디자인 수치 기준으로 이미지 리사이징
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
    
    // 메인 스케줄러에서 처리
    func retrieveCacheObservable(posefeed: [PosePick], isFilterSection: Bool = true) -> Observable<[BookmarkFeedCellViewModel]> {
        
        let viewModelObservable = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        
        posefeed.forEach { posepick in
            ImageCache.default.retrieveImage(forKey: posepick.poseInfo.imageKey, options: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    if let image = value.image {
                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                        isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                        
                        let viewModel = BookmarkFeedCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId)
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else {
                        guard let url = URL(string: posepick.poseInfo.imageKey) else { return }
                        KingfisherManager.shared.retrieveImage(with: url, options: [.downloader(self.imageDownloader)]) { downloadResult in
                            switch downloadResult {
                            case .success(let downloadImage):
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                                isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                                
                                let viewModel = BookmarkFeedCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId)
                                viewModelObservable.accept(viewModelObservable.value + [viewModel])
                            case .failure:
                                return
                            }
                        }
                    }
                case .failure:
                    return
                }
            }
        }
        return viewModelObservable.asObservable().skip(while: { $0.count < posefeed.count })
    }
}
