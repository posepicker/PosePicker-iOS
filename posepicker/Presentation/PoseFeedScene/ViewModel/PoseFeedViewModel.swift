//
//  PoseFeedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/3/24.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

final class PoseFeedViewModel {
    weak var coordinator: PoseFeedCoordinator?
    private var posefeedUseCase: PoseFeedUseCase
    
    init(coordinator: PoseFeedCoordinator?, posefeedUseCase: PoseFeedUseCase) {
        self.coordinator = coordinator
        self.posefeedUseCase = posefeedUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let infiniteScrollEvent: Observable<Void>
        let filterButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let dataSource: RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>>
        let contents = PublishRelay<[Section<PoseFeedPhotoCellViewModel>]>()
        let isLoading = BehaviorRelay<Bool>(value: false)
        let isLastPage = BehaviorRelay<Bool>(value: true)
        let filteredSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let recommendedSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(dataSource: configureDataSource(disposeBag: disposeBag))
        
        let currentPage = BehaviorRelay<Int>(value: 0)
        
        /// 1. viewDidLoad 이후 초기 데이터 요청
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                currentPage.accept(0)
                self?.posefeedUseCase.fetchFeedContents(peopleCount: "", frameCount: "", filterTags: [], pageNumber: 0)
            })
            .disposed(by: disposeBag)
        
        /// 2. 무한스크롤 트리거 로직
        input.infiniteScrollEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                let nextPage = currentPage.value + 1
                currentPage.accept(nextPage)
                self?.posefeedUseCase.fetchFeedContents(peopleCount: "", frameCount: "", filterTags: [], pageNumber: nextPage)
            })
            .disposed(by: disposeBag)
        
        /// 3. 포즈피드 유스케이스에서 무한스크롤 last값 불러오기
        self.posefeedUseCase
            .isLastPage
            .subscribe(onNext: {
                output.isLastPage.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 4. 포즈피드 유스케이스에서 피드 컨텐츠 가져와서 뷰 컨트롤러에 바인딩하기
        self.posefeedUseCase
            .feedContents
            .subscribe(onNext: {
                output.contents.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 5. 포즈피드 유스케이스 컨텐츠 로드 끝나는 시점 가져오기
        self.posefeedUseCase
            .contentLoaded
            .subscribe(onNext: {
                output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        /// 6. 포즈피드 유스케이스에서 필터 컨텐츠들 사이즈 가져오기
        self.posefeedUseCase
            .filterSectionContentSizes
            .subscribe(onNext: {
                output.filteredSectionContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 7. 포즈피드 유스케이스에서 추천 컨텐츠들 사이즈 가져오기
        self.posefeedUseCase
            .recommendSectionContentSizes
            .subscribe(onNext: {
                output.recommendedSectionContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 8. 필터 버튼 탭 후 필터 세팅 모달창 present
        input.filterButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentFilterModal()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func configureDataSource(disposeBag: DisposeBag) -> RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>>(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PoseFeedPhotoCell.identifier, for: indexPath) as? PoseFeedPhotoCell else { return UICollectionViewCell() }
            cell.disposeBag = DisposeBag()
            cell.viewModel = item
            cell.bind()
            
            /// 북마크 버튼 눌렸을때 로그인 여부 체크 -> 로그인 여부를 뭘로 체크할 것인가?
            /// 키체인 토큰 조회해서 존재하면 북마크 API 요청
            cell.bookmarkButton.rx.tap
                .withUnretained(self)
                .subscribe { [weak item] (owner, _) in
                    guard let item = item else { return }
                    if true {
                        // API요청 보내기
//                        if item.bookmarkCheck.value {
//                            owner.bookmarkRemoveButtonTapped.onNext(item.poseId.value)
//                        } else {
//                            owner.bookmarkButtonTapped.onNext(item.poseId.value)
//                        }
//                        item.bookmarkCheck.accept(!item.bookmarkCheck.value)
                    } else {
//                        owner.presentLoginPopUp.onNext(())
                    }
                }
                .disposed(by: cell.disposeBag)
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
    }
}
