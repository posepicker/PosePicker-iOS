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
    
    var bookmarkContentSizes = BehaviorRelay<[CGSize]>(value: [])
    let bookmarkToPosefeedButtonTrigger = PublishSubject<Void>()
    
    var currentPage = 0
    var isLast = false
    var isLoading = false
    
    let bookmarkButtonTapped = PublishSubject<Int>() // 데이터소스 객체의 북마크 버튼 탭 이후 북마크 등록요청
    let bookmarkRemoveButtonTapped = PublishSubject<Int>() // 북마크 삭제 탭 트리거
    
    /// 포즈피드 컬렉션뷰 datasource 정의
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<Section<BookmarkFeedCellViewModel>>(configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkFeedCell.identifier, for: indexPath) as? BookmarkFeedCell else { return UICollectionViewCell() }
        cell.disposeBag = DisposeBag()
        cell.viewModel = item
        cell.bind()
        
        cell.bookmarkButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if AppCoordinator.loginState {
                    // API요청 보내기
                    if item.bookmarkCheck.value {
                        self.bookmarkRemoveButtonTapped.onNext(item.poseId.value)
                    } else {
                        self.bookmarkButtonTapped.onNext(item.poseId.value)
                    }
                    item.bookmarkCheck.accept(!item.bookmarkCheck.value)
                }
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkEmptyView.identifier, for: indexPath) as! BookmarkEmptyView
            
            header.transitionButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.bookmarkToPosefeedButtonTrigger.onNext(())
                })
                .disposed(by: self.disposeBag)
            
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
        var bookmarkSelection: ControlEvent<BookmarkFeedCellViewModel>
        var bookmarkFromPoseId: Observable<(Int, Bool)>
    }
    
    struct Output {
        let sectionItems: Observable<[Section<BookmarkFeedCellViewModel>]>
        let isEmpty: Driver<Bool?>
        let isLoading: Observable<Bool>
        let transitionToPoseFeed: Observable<Void>
        let bookmarkDetailViewPush: Driver<BookmarkDetailViewModel?>
    }
    
    func transform(input: Input) -> Output {
        let isEmpty = BehaviorRelay<Bool?>(value: nil)
        let sectionItems = BehaviorRelay<[Section<BookmarkFeedCellViewModel>]>(value: [Section(header: "", items: [])])
        let loadable = BehaviorRelay<Bool>(value: false)
        let bookmarkDetailViewModel = BehaviorRelay<BookmarkDetailViewModel?>(value: nil)
        
        /// 1. 뷰 로드 이후 컬렉션뷰 셀 아이템 API 요청
        /// 2. 뷰 초기 로드 외에도 북마크 삭제 이후 리프레시를 위해 사용됨
        input.viewDidLoadTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                self.beginLoading()
                loadable.accept(true)
                sectionItems.accept([Section(header: "", items: [])]) // 섹션 아이템 초기화
                
                self.currentPage = 0
                self.isLast = false
                
                if let _ = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.KeychainKeyParameters.refreshToken)
                {
                    return apiSession.requestSingle(.retrieveBookmarkFeed(pageNumber: self.currentPage, pageSize: 8)).asObservable()
                } else {
                    return Observable<PoseFeed>.empty()
                }
                
            }
            .map { [unowned self] in
                self.currentPage += 1
                self.isLast = $0.last
                self.endLoading()
                loadable.accept(false)
                return $0.content
            }
            .flatMapLatest { [unowned self] posefeed -> Observable<[BookmarkFeedCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
            }
            .subscribe(onNext: {
                self.endLoading()
                loadable.accept(false)
                
                var items = sectionItems.value.first?.items ?? []
                items.append(contentsOf: $0)
                let newSection = Section(header: "", items: items)
                sectionItems.accept([newSection])
                isEmpty.accept($0.isEmpty ? true : false)
            })
            .disposed(by: disposeBag)
        
        /// 2. 무한스크롤 다음 페이지 트리거
        input.nextPageTrigger
            .flatMapLatest { [unowned self] _ -> Observable<PoseFeed> in
                self.beginLoading()
                loadable.accept(true)
                
                if let userIdString = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.userId),
                   let userId = Int64(userIdString)
                {
                    return apiSession.requestSingle(.retrieveBookmarkFeed(pageNumber: self.currentPage, pageSize: 8)).asObservable()
                } else {
                    return Observable<PoseFeed>.empty()
                }
            }
            .map { [unowned self] in
                self.currentPage += 1
                self.isLast = $0.last
                return $0.content
            }
            .flatMapLatest { [unowned self] posefeed -> Observable<[BookmarkFeedCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
            }
            .subscribe(onNext: {
                self.endLoading()
                loadable.accept(false)
                
                var items = sectionItems.value.first?.items ?? []
                items.append(contentsOf: $0)
                let newSection = Section(header: "", items: items)
                sectionItems.accept([newSection])
                isEmpty.accept(true)
            })
            .disposed(by: disposeBag)
        
        /// 3. 셀 탭 이후 디테일 뷰 표시를 위한 PoseDetailViewModel 뷰모델 바인딩
        input.bookmarkSelection
            .flatMapLatest { [unowned self] viewModel -> Observable<Pose> in
                return self.apiSession.requestSingle(.retrievePoseDetail(poseId: viewModel.poseId.value)).asObservable()
            }
            .subscribe(onNext: {
                let viewModel = BookmarkDetailViewModel(poseDetailData: $0)
                bookmarkDetailViewModel.accept(viewModel)
            })
            .disposed(by: disposeBag)
        
        /// 4. 북마크 재등록
        self.bookmarkButtonTapped
            .flatMapLatest { [unowned self] poseId -> Observable<BookmarkResponse> in
                return self.apiSession.requestSingle(.registerBookmark(poseId: poseId)).asObservable()
            }
            .subscribe(onNext: { _ in
                print("등록 완료!")
            })
            .disposed(by: disposeBag)
        
        /// 5. 북마크 삭제
        self.bookmarkRemoveButtonTapped
            .flatMapLatest { [unowned self] poseId -> Observable<BookmarkResponse> in
                return self.apiSession.requestSingle(.deleteBookmark(poseId: poseId)).asObservable()
            }
            .subscribe(onNext: { _ in
                print("삭제 완료!")
            })
            .disposed(by: disposeBag)
        
        input.bookmarkFromPoseId
            .subscribe(onNext: { [unowned sectionItems] poseId, bookmarkCheck in
                let bookmarkValue: [BookmarkFeedCellViewModel] = sectionItems.value.first?.items ?? []
                if let checkedIndexInFilter = bookmarkValue.firstIndex(where: {
                    return $0.poseId.value == poseId
                }) {
                    bookmarkValue[checkedIndexInFilter].bookmarkCheck.accept(bookmarkCheck)
                    sectionItems.accept([Section(header: "", items: bookmarkValue)])
                    return
                }
            })
            .disposed(by: disposeBag)
        
        return Output(sectionItems: sectionItems.asObservable(), isEmpty: isEmpty.asDriver(), isLoading: loadable.asObservable(), transitionToPoseFeed: self.bookmarkToPosefeedButtonTrigger, bookmarkDetailViewPush: bookmarkDetailViewModel.asDriver())
    }
    
    // MARK: - 킹피셔 이미지 캐싱 관련 함수들
    /// 디자인 수치 기준으로 이미지 리사이징
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
    
    // 메인 스케줄러에서 처리
    func retrieveCacheObservable(posefeed: [Pose]) -> Observable<[BookmarkFeedCellViewModel]> {
        
        let viewModelObservable = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        
        posefeed.forEach { posepick in
            ImageCache.default.retrieveImage(forKey: posepick.poseInfo.imageKey, options: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    if let image = value.image {
                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                         self.bookmarkContentSizes.accept(self.bookmarkContentSizes.value + [newSizeImage.size])
                        
                        let viewModel = BookmarkFeedCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else {
                        guard let url = URL(string: posepick.poseInfo.imageKey) else { return }
                        KingfisherManager.shared.retrieveImage(with: url, options: [.downloader(self.imageDownloader)]) { downloadResult in
                            switch downloadResult {
                            case .success(let downloadImage):
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                                 self.bookmarkContentSizes.accept(self.bookmarkContentSizes.value + [newSizeImage.size])
                                
                                let viewModel = BookmarkFeedCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
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
    
    /// 로딩상태 업데이트
    func beginLoading() {
        self.isLoading = true
    }
    
    func endLoading() {
        self.isLoading = false
    }
}
