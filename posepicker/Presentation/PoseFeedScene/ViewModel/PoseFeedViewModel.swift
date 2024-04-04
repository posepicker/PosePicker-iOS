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
    private var isLoading = PublishRelay<Bool>()
    
    init(coordinator: PoseFeedCoordinator?, posefeedUseCase: PoseFeedUseCase) {
        self.coordinator = coordinator
        self.posefeedUseCase = posefeedUseCase
    }
    
    struct Input {
        let currentPage: Observable<Int>
    }
    
    struct Output {
        let dataSource: RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>>
        let contents = PublishRelay<[Section<PoseFeedPhotoCellViewModel>]>()
        let isLoading = PublishRelay<Bool>()
        let filteredSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let recommendedSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(dataSource: configureDataSource(disposeBag: disposeBag))
        
        input.currentPage
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                self?.posefeedUseCase.fetchFeedContents(peopleCount: "2인", frameCount: "4컷", filterTags: ["커플"], pageNumber: $0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .feedContents
            .subscribe(onNext: {
                output.isLoading.accept(false)
                output.contents.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .filterSectionContentSizes
            .subscribe(onNext: {
                output.filteredSectionContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .recommendSectionContentSizes
            .subscribe(onNext: {
                output.recommendedSectionContentSizes.accept($0)
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
