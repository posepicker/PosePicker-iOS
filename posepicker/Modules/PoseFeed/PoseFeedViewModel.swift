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
    
    var filteredContentSizes = BehaviorRelay<[CGSize]>(value: [])
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
        let filterButtonTapped: ControlEvent<Void> // O
        let tagItems: Observable<(String, String, [FilterTags])> // O
        let filterTagSelection: Observable<RegisteredFilterCellViewModel> // O
        let filterRegisterCompleted: ControlEvent<Void> // O
        let poseFeedFilterViewIsPresenting: Observable<Bool> // O
        let viewDidLoadTrigger: Observable<Void>
    }
    
    struct Output {
        let presentModal: Driver<Void> // O
        let filterTagItems: Driver<[RegisteredFilterCellViewModel]> // O
        let deleteTargetFilterTag: Driver<FilterTags?>
        let deleteTargetCountTag: Driver<CountTagType?>
        let sectionItems: Observable<[PoseSection]>
    }
    
    // MARK: - 이미지 하나씩 바인딩하지 말고 모두 다 받고 진행
    func transform(input: Input) -> Output {
        
        let tagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
        let deleteTargetFilterTag = BehaviorRelay<FilterTags?>(value: nil)
        let deleteTargetCountTag = BehaviorRelay<CountTagType?>(value: nil)
        
        let filterSection = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let recommendSection = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let sectionItems = BehaviorRelay<[PoseSection]>(value: [PoseSection(header: "", items: []), PoseSection(header: "이런 포즈는 어때요?", items: [])])
        
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
        
        /// 1. 포즈피드 초기 진입시 데이터 요청
        input.viewDidLoadTrigger
            .flatMapLatest { _ -> Observable<PoseFeed> in self.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: 0, pageSize: 8)).asObservable() }
            .map { $0.content }
            .flatMapLatest { [unowned self] posefeed -> Observable<[PoseFeedPhotoCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
            }
            .subscribe(onNext: {
                filterSection.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 필터 섹션 & 추천 섹션 결합 후 셀 아이템에 바인딩
        Observable.combineLatest(filterSection, recommendSection)
            .subscribe(onNext: { filter, recommend in
                let newSectionItems = [PoseSection(header: "", items: filter), PoseSection(header: "이런 포즈는 어때요?", items: recommend)]
                sectionItems.accept(newSectionItems)
            })
            .disposed(by: disposeBag)
            
        
        return Output(presentModal: input.filterButtonTapped.asDriver(), filterTagItems: tagItems.asDriver(), deleteTargetFilterTag: deleteTargetFilterTag.asDriver(), deleteTargetCountTag: deleteTargetCountTag.asDriver(), sectionItems: sectionItems.asObservable())
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
    
    func retrieveCacheObservable(posefeed: [PosePick], isFilterSection: Bool = true) -> Observable<[PoseFeedPhotoCellViewModel]> {
        let viewModelObservable = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        
        posefeed.forEach { posepick in
            ImageCache.default.retrieveImage(forKey: posepick.poseInfo.imageKey, options: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    if let image = value.image {
                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                        isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                        
                        let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId)
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else {
                        guard let url = URL(string: posepick.poseInfo.imageKey) else { return }
                        KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                            switch downloadResult {
                            case .success(let downloadImage):
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                                isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                                
                                let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId)
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
