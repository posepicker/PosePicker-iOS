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
    private var commonUseCase: CommonUseCase
    
    init(coordinator: PoseFeedCoordinator?, posefeedUseCase: PoseFeedUseCase, commonUseCase: CommonUseCase) {
        self.coordinator = coordinator
        self.posefeedUseCase = posefeedUseCase
        self.commonUseCase = commonUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let infiniteScrollEvent: Observable<Void>
        let filterButtonTapEvent: Observable<Void>
        let dismissFilterModalEvent: Observable<[RegisteredFilterCellViewModel]>
        let filterTagTapEvent: Observable<RegisteredFilterCellViewModel>
        let posefeedPhotoCellTapEvent: Observable<PoseFeedPhotoCellViewModel>
        let dismissPoseDetailEvent: Observable<RegisteredFilterCellViewModel>
    }
    
    struct Output {
        let dataSource: RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>>
        let contents = PublishRelay<[Section<PoseFeedPhotoCellViewModel>]>()
        let isLoading = BehaviorRelay<Bool>(value: false)
        let isLastPage = BehaviorRelay<Bool>(value: true)
        let filteredSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let recommendedSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let registeredTagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(dataSource: configureDataSource(disposeBag: disposeBag))
        
        let currentPage = BehaviorRelay<Int>(value: 0)
        let apiRequestParameters = BehaviorRelay<[String]>(value: ["전체", "전체"])
        
        /// 1. viewDidLoad 이후 초기 데이터 요청
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                currentPage.accept(0)
                self?.posefeedUseCase.fetchFeedContents(peopleCount: apiRequestParameters.value[0], frameCount: apiRequestParameters.value[1], filterTags: [], pageNumber: 0)
            })
            .disposed(by: disposeBag)
        
        /// 2. 무한스크롤 트리거 로직
        input.infiniteScrollEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                let nextPage = currentPage.value + 1
                currentPage.accept(nextPage)
                
                self?.posefeedUseCase.fetchFeedContents(
                    peopleCount: apiRequestParameters.value[0],
                    frameCount: apiRequestParameters.value[1],
                    filterTags: apiRequestParameters.value[2...].map { String($0) },
                    pageNumber: nextPage
                )
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
                self?.coordinator?.presentFilterModal(currentTags: apiRequestParameters.value)
            })
            .disposed(by: disposeBag)
        
        /// 9. 모달에서 세팅된 태그들을 컬렉션뷰에 바인딩
        input.dismissFilterModalEvent
            .subscribe(onNext: { registeredTagViewModels in
                var viewModels = registeredTagViewModels
                
                if let removeTargetIndex = viewModels.firstIndex(where: {$0.title.value == "전체"}) {
                    viewModels.remove(at: removeTargetIndex)
                }
                
                if let removeTargetIndex = viewModels.firstIndex(where: {$0.title.value == "전체"}) {
                    viewModels.remove(at: removeTargetIndex)
                }
                output.registeredTagItems.accept(viewModels)
            })
            .disposed(by: disposeBag)
        
        /// 10. 모달에서 세팅된 태그들로 API 요청
        input.dismissFilterModalEvent
            .subscribe(onNext: { [weak self] registeredTagViewModels in
                guard let peopleCountTag = PeopleCountTags.getTagFromTitle(title: registeredTagViewModels[0].title.value),
                      let frameCountTag = FrameCountTags.getTagFromTitle(title: registeredTagViewModels[1].title.value) else {
                    return
                }
                
                let filterTags = registeredTagViewModels[2...].map { $0.title.value }
                apiRequestParameters.accept([peopleCountTag.rawValue, frameCountTag.rawValue] + filterTags)
                
                self?.posefeedUseCase.fetchFeedContents(
                    peopleCount: apiRequestParameters.value[0],
                    frameCount: apiRequestParameters.value[1],
                    filterTags: apiRequestParameters.value[2...].map { String($0) },
                    pageNumber: 0
                )
                
                currentPage.accept(0)
                output.isLoading.accept(true)
            })
            .disposed(by: disposeBag)
        
        /// 11. 포즈피드 필터 태그 삭제 팝업창 present
        input.filterTagTapEvent
            .flatMapLatest { [weak self] viewModel -> Observable<String?> in
                guard let self = self,
                      let coordinator = self.coordinator else { return .empty() }
                return coordinator.presentTagRemovePopup(title: viewModel.title.value, disposeBag: disposeBag)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] removeTargetTag in
                var apiRequestParams = apiRequestParameters.value
                if let index
                    = apiRequestParams.firstIndex(where: {
                    $0 == removeTargetTag
                    }),
                   removeTargetTag != "전체" {
                    
                    // 인원 수 태그 삭제 혹은 프레임 수 태그는 API 파라미터 삭제 말고 교체로 변경
                    if removeTargetTag.last! == "인" {
                        apiRequestParams[index] = "전체"
                    } else if removeTargetTag.last! == "컷" {
                        apiRequestParams[index] = "전체"
                    } else {
                        apiRequestParams.remove(at: index)
                    }
                }
                apiRequestParameters.accept(apiRequestParams)
                
                var registeredTags = output.registeredTagItems.value
                registeredTags.removeAll(where: {
                    $0.title.value == removeTargetTag
                })
                output.registeredTagItems.accept(registeredTags)
                
                self?.posefeedUseCase.fetchFeedContents(
                    peopleCount: apiRequestParams[0],
                    frameCount: apiRequestParams[1],
                    filterTags: apiRequestParams[2...].map { String($0) },
                    pageNumber: 0
                )
            })
            .disposed(by: disposeBag)
        
        input.posefeedPhotoCellTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentPoseDetail(viewModel: $0)
            })
            .disposed(by: disposeBag)
        
        input.dismissPoseDetailEvent
            .subscribe(onNext: { [weak self] in
                var apiRequestParams = apiRequestParameters.value
                apiRequestParams[0] = "전체"
                apiRequestParams[1] = "전체"
                apiRequestParams.removeSubrange(2...)
                apiRequestParams.append($0.title.value)
                apiRequestParameters.accept(apiRequestParams)
                
                self?.posefeedUseCase.fetchFeedContents(
                    peopleCount: apiRequestParameters.value[0],
                    frameCount: apiRequestParameters.value[1],
                    filterTags: apiRequestParameters.value[2...].map { String($0) },
                    pageNumber: 0
                )
                
                var registeredTags = output.registeredTagItems.value
                registeredTags.append(RegisteredFilterCellViewModel(title: $0.title.value))
                output.registeredTagItems.accept([RegisteredFilterCellViewModel(title: $0.title.value)])
                
                currentPage.accept(0)
                output.isLoading.accept(true)
            })
            .disposed(by: disposeBag)
        
        posefeedUseCase.bookmarkTaskCompleted
            .subscribe(onNext: {
                if $0 {
                    print("북마크 등록 완료")
                } else {
                    print("북마크 체크 아이디값 관련 확인필요")
                }
            })
            .disposed(by: disposeBag)
        
        self.commonUseCase.loginCompleted
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                guard let coordinator = owner.coordinator else { return }
                coordinator.loginDelegate?.coordinatorLoginCompleted(childCoordinator: coordinator)
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
                    if UserDefaults.standard.bool(forKey: K.SocialLogin.isLoggedIn) {
                        // API요청 보내기
                        owner.posefeedUseCase.bookmarkContent(poseId: item.poseId.value, currentChecked: item.bookmarkCheck.value)
                        item.bookmarkCheck.accept(!item.bookmarkCheck.value)
                    } else {
                        // 로그인 화면 present
                        guard let coordinator = owner.coordinator else { return }
                        coordinator.loginDelegate?.coordinatorLoginRequested(childCoordinator: coordinator)
                            .subscribe(onNext: {
                                switch $0 {
                                case .apple:
                                    guard let idToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.idToken) else { return }
                                    owner.commonUseCase.loginWithApple(idToken: idToken)
                                case .kakao:
                                    owner.commonUseCase.loginWithKakao()
                                }
                            })
                            .disposed(by: disposeBag)
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
