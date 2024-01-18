//
//  PoseFeedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import Alamofire
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
    var currentPage = 0
    var isLast = false
    
    let presentLoginPopUp = PublishSubject<Void>() // 셀 내의 북마크 버튼 탭 이벤트를 데이터소스 내에서 방출 가능하여 뷰모델 내에 옵저버블을 추가해두고, 포즈피드 뷰 컨트롤러에서 구독
    let bookmarkButtonTapped = PublishSubject<Int>() // 데이터소스 객체의 북마크 버튼 탭 이후 북마크 등록요청
    let bookmarkRemoveButtonTapped = PublishSubject<Int>() // 북마크 삭제 탭 트리거
    let nextPageRequestTrigger = BehaviorRelay<PoseFeedViewModel.RequestState>(value: .idle)
    
    /// 포즈피드 컬렉션뷰 datasource 정의
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<PoseSection>(configureCell: { dataSource, collectionView, indexPath, item in
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
                if AppCoordinator.loginState {
                    // API요청 보내기
                    if item.bookmarkCheck.value {
                        owner.bookmarkRemoveButtonTapped.onNext(item.poseId.value)
                    } else {
                        owner.bookmarkButtonTapped.onNext(item.poseId.value)
                    }
                    item.bookmarkCheck.accept(!item.bookmarkCheck.value)
                } else {
                    owner.presentLoginPopUp.onNext(())
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
    
    enum CountTagType {
        case head
        case frame
    }
    
    enum RequestState {
        case idle
        case request
    }
    
    struct Input {
        let filterButtonTapped: ControlEvent<Void> // O
        let tagItems: Observable<(PeopleCountTags, FrameCountTags, [FilterTags], String?)> // 이 외에도 일반 스트링값이 있을 수 있다
        let filterTagSelection: Observable<RegisteredFilterCellViewModel> // O
        let filterRegisterCompleted: Observable<Void> // O
        let poseFeedFilterViewIsPresenting: BehaviorRelay<Bool> // O
        let requestAllPoseTrigger: Observable<Void>
        let poseFeedSelection: ControlEvent<PoseFeedPhotoCellViewModel>
        let modalDismissWithTag: Observable<String>
        
        /// 토큰 세팅 관련 옵저버블
        let appleIdentityTokenTrigger: Observable<String>
        let kakaoLoginTrigger: Observable<(String, Int64)>
        
        /// 포즈 아이디값을 받아서 bookmarkCheck 속성 바인딩을 위한 옵저버블
        /// API 요청은 하지 않음 (북마크 뷰에서 이미 처리되고 오는 상황만 가정)
        let bookmarkFromPoseId: Observable<(Int, Bool)>
        
        // 필터뷰 dismiss 상태값에 따라 API요청 여부 분기처리
        let dismissState: BehaviorRelay<PoseFeedFilterViewModel.DismissState>
    }
    
    struct Output {
        let presentModal: Driver<Void> // O
        let filterTagItems: Driver<[RegisteredFilterCellViewModel]> // O
        let deleteTargetFilterTag: Driver<FilterTags?>
        let deleteTargetCountTag: Driver<CountTagType?>
        let deleteSubTag: Driver<Void>
        let sectionItems: Observable<[PoseSection]>
        let poseDetailViewPush: Observable<PoseDetailViewModel?>
        let isLoading: Observable<Bool>
        let dismissLoginView: Observable<Void>
    }
    
    // MARK: - 이미지 하나씩 바인딩하지 말고 모두 다 받고 진행
    func transform(input: Input) -> Output {
        
        let tagItems = BehaviorRelay<[RegisteredFilterCellViewModel]>(value: [])
        let deleteTargetFilterTag = BehaviorRelay<FilterTags?>(value: nil)
        let deleteTargetCountTag = BehaviorRelay<CountTagType?>(value: nil) // FIXME: 리팩토링 대상
        let deleteSubTag = PublishSubject<Void>()
        
        let filterSection = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let recommendSection = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        let recommendContents = BehaviorRelay<RecommendedContents?>(value: nil)
        
        let sectionItems = BehaviorRelay<[PoseSection]>(value: [PoseSection(header: "", items: []), PoseSection(header: "이런 포즈는 어때요?", items: [])])
        let poseDetailViewModel = BehaviorRelay<PoseDetailViewModel?>(value: nil)
        let queryParameters = BehaviorRelay<[String]>(value: [])
        
        let loadable = BehaviorRelay<Bool>(value: false)
        let dismissLoginView = PublishSubject<Void>()
        let kakaoAccountObservable = BehaviorRelay<(String, Int64)>(value: ("", -1))
        let authCodeObservable = BehaviorRelay<String>(value: "")
        
        /// 필터 등록 완료 + 필터 모달이 Present 상태일때
        /// 인원 수 & 프레임 수 셀렉션으로부터 데이터 추출
        input.filterRegisterCompleted
            .flatMapLatest { () -> Observable<Bool> in
                return input.poseFeedFilterViewIsPresenting.asObservable()
            }
            .flatMapLatest { isPresenting -> Observable<(PeopleCountTags, FrameCountTags, [FilterTags], String?)> in
                if isPresenting {
                    return Observable<(PeopleCountTags, FrameCountTags, [FilterTags], String?)>.empty()
                } else {
                    return input.tagItems
                }
            }
            .flatMapLatest { [unowned self] (headcount, frameCount, filterTags, registeredSubTag) -> Observable<[String]> in
                
                self.currentPage = 0 // 태그 세팅 이후 페이지값 0으로 초기화
                var subTag: [String] = []
                if let tag = registeredSubTag {
                    subTag.append(tag)
                }
                return BehaviorRelay<[String]>(value: [headcount.rawValue, frameCount.rawValue] + filterTags.map { $0.rawValue} + subTag ).asObservable()
            }
            .subscribe(onNext: { tags in
                if input.dismissState.value == .normal {
                    return
                }
                
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
                
                // 일반 태그인 경우
                if let filterTag = FilterTags.getTagFromTitle(title: $0.title.value) {
                    deleteTargetFilterTag.accept(filterTag)
                    return
                }
                
                // 인원 수 태그인 경우
                if let _ = PeopleCountTags.getTagFromTitle(title: $0.title.value) {
                    deleteTargetCountTag.accept(.head)
                    return
                }
                
                // 프레임 수 태그인 경우
                if let _ = FrameCountTags.getTagFromTitle(title: $0.title.value) {
                    deleteTargetCountTag.accept(.frame)
                    return
                }
                
                /// 필터 세팅되지 않고 키워드 설정부터 진행한 경우
                /// queryParameter 배열값이 ["전체", "전체"]가 아니어서 isEmpty 옵저버블 리턴
                /// 따라서 쿼리 하나일때 삭제 인풋이 들어오면 ["전체", "전체"]로 쿼리를 세팅해야 요청 이루어짐
                
                // tagItems에서 서브태그 바로 삭제
                deleteSubTag.onNext(())
                let singleTag = $0
                if let index = tagItems.value.firstIndex(where: { viewModel in
                    singleTag.title.value == viewModel.title.value
                }) {
                    var tagItemsValue = tagItems.value
                    tagItemsValue.remove(at: index)
                    tagItems.accept(tagItemsValue)
                }
                
                if let index = queryParameters.value.firstIndex(where: { parameter in
                    singleTag.title.value == parameter
                }) {
                    var queryParameterValue = queryParameters.value
                    queryParameterValue.remove(at: index)
                    if queryParameterValue.isEmpty { queryParameterValue.append(contentsOf: ["전체", "전체"]) }
                    queryParameters.accept(queryParameterValue)
                }
            })
            .disposed(by: disposeBag)
        
        /// 1. 포즈피드 초기 진입시 데이터 요청
        input.requestAllPoseTrigger
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<FilteredPose> in
                loadable.accept(true)
                return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: "전체", frameCount: "전체", filterTags: [], pageNumber: 0)).asObservable()
            }
            .map { $0.filteredContents?.content ?? [] }
            .withUnretained(self)
            .flatMapLatest { owner, posefeed -> Observable<[PoseFeedPhotoCellViewModel]> in
                return self.retrieveCacheObservable(posefeed: posefeed)
                    .skip(while: { $0.count < posefeed.count })
            }
            .subscribe(onNext: {
                loadable.accept(false)
                filterSection.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 2-1. 포즈피드 필터 세팅 이후 데이터 요청 (필터링 데이터 세팅)
        /// 빈 배열 accept 전에 전체 순회하며 뷰모델 오브젝트 해제하기
        queryParameters
            .withUnretained(self)
            .flatMapLatest { owner, tags -> Observable<FilteredPose> in
                if tags.isEmpty { return Observable<FilteredPose>.empty() }

                // MARK: - 초기화 로직
                owner.filteredContentSizes.accept([])
                owner.recommendedContentsSizes.accept([])
                owner.currentPage = 0
                owner.beginLoading()
                filterSection.accept([])
                recommendSection.accept([])
                recommendContents.accept(nil)
                loadable.accept(true)
                
                let filterTags: [String] = tags.count > 2 ? Array(tags[2..<tags.count]) : []
                
                // MARK: - 상세 뷰에서 셀 탭을 통해 모달로 태그 세팅되었을때
                if tags.count == 1 {
                    // 인원 수 태그일때
                    if let _ = FilterTags.getNumberFromPeopleCountString(countString: tags.first!) {
                        return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: tags.first!, frameCount: "전체", filterTags: [], pageNumber: 0)).asObservable()
                    }
                    
                    // 프레임 수 태그일때
                    if let _ = FilterTags.getNumberFromFrameCountString(countString: tags.first!) {
                        return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: "전체", frameCount: tags.first!, filterTags: [], pageNumber: 0)).asObservable()
                    }
                    
                    return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: "전체", frameCount: "전체", filterTags: tags, pageNumber: 0)).asObservable()
                }
                
                return self.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: tags[0], frameCount: tags[1], filterTags: filterTags, pageNumber: self.currentPage)).asObservable()
            }
            .withUnretained(self)
            .flatMapLatest { owner, filteredPose -> Observable<[PoseFeedPhotoCellViewModel]> in
                owner.isLast = filteredPose.filteredContents?.last ?? true // 추천섹션 데이터 accept처리
                recommendContents.accept(filteredPose.recommendedContents)
                
                guard let contents = filteredPose.filteredContents?.content else { return Observable<[PoseFeedPhotoCellViewModel]>.empty() }
                print("retrievedCacheObservable called in queryParameters ..")
                return owner.retrieveCacheObservable(posefeed: contents)
                    .skip(while: { $0.count < contents.count })
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, filterContents in
                loadable.accept(false)
                owner.endLoading()
                filterSection.accept(filterContents) // 기존 필터링 섹션 데이터 전체 초기화 후 새로 가져온 데이터로 교체
            })
            .disposed(by: disposeBag)
        
        /// 2-2. 포즈피드 필터 세팅 이후 추천 컨텐츠
        /// 추천컨텐츠는 반드시 필터링 컨텐츠가 캐시에서 모두 로드된 이후에 처리
        recommendContents.asObservable()
            .compactMap { $0 }
            .withUnretained(self)
            .flatMapLatest { owner, recommendedContents -> Observable<[PoseFeedPhotoCellViewModel]> in
                owner.isLast = recommendedContents.last
                owner.endLoading()
                loadable.accept(false)
                return owner.retrieveCacheObservable(posefeed: recommendedContents.content, isFilterSection: false)
                    .skip(while: { $0.count < recommendedContents.content.count })
            }
            .subscribe(onNext: { [weak recommendSection] in
                guard let recommendSection = recommendSection else { return }
                recommendSection.accept(recommendSection.value + $0)
            })
            .disposed(by: disposeBag)
        
        /// 3. 셀 탭 이후 디테일 뷰 표시를 위한 PoseDetailViewModel 뷰모델 바인딩
        input.poseFeedSelection
            .withUnretained(self)
            .flatMapLatest { owner, viewModel -> Observable<PosePick> in
                return owner.apiSession.requestSingle(.retrievePoseDetail(poseId: viewModel.poseId.value)).asObservable()
            }
            .subscribe(onNext: { posepick in
                let viewModel = PoseDetailViewModel(poseDetailData: posepick)
                poseDetailViewModel.accept(viewModel)
            })
            .disposed(by: disposeBag)
        
        /// 4-1. 다음 페이지 요청 트리거 - 쿼리 세팅 안된 상태 (포즈피드 초기 진입 이후의 무한스크롤)
        self.nextPageRequestTrigger
            .flatMapLatest {
                if $0 == .idle {
                    return BehaviorRelay<[String]>.empty()
                } else {
                    return queryParameters.asObservable()
                }
            }
            .withUnretained(self)
            .flatMapLatest { owner, querySet -> Observable<PoseFeed> in
                if querySet.isEmpty {
                    owner.beginLoading() // 로딩 시작
                    loadable.accept(true)
                    owner.currentPage += 1
                    return owner.apiSession.requestSingle(.retrieveAllPoseFeed(pageNumber: owner.currentPage, pageSize: 8)).asObservable()
                } else {
                    return Observable<PoseFeed>.empty()
                }
            }
            .withUnretained(self)
            .flatMapLatest { owner, posefeed -> Observable<[PoseFeedPhotoCellViewModel]> in
                owner.isLast = posefeed.last
                return owner.retrieveCacheObservable(posefeed: posefeed.content)
                    .skip(while: { $0.count < posefeed.content.count })
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, filterContents in
                owner.endLoading() // 로딩 끝
                loadable.accept(false)
                filterSection.accept(filterSection.value + filterContents)
            })
            .disposed(by: disposeBag)
        
        /// 4-2. 다음 페이지 요청 트리거 - 쿼리 세팅 된 상태 (포즈피드 진입 후 필터 세팅된 이후의 무한스크롤)
        self.nextPageRequestTrigger
            .flatMapLatest {
                if $0 == .idle {
                    return BehaviorRelay<[String]>.empty()
                } else {
                    return queryParameters.asObservable()
                }
            }
            .withUnretained(self)
            .flatMapLatest { owner, querySet -> Observable<FilteredPose> in
                if querySet.isEmpty {
                    return Observable<FilteredPose>.empty()
                } else {
                    // 인원 수 & 프레임 수 제외한 나머지 태그들 추출하는 로직
                    let filterTags: [String] = querySet.count > 2 ? Array(querySet[2..<querySet.count]) : []
                    owner.beginLoading()
                    loadable.accept(true)
                    owner.currentPage += 1

                    // MARK: - 상세 뷰에서 셀 탭을 통해 모달로 태그 세팅되었을때의 무한스크롤
                    // MARK: - 해당 엣지케이스는 필터태그 세팅이 한번도 이루어지지 않았을 때에만 해당
                    if querySet.count == 1 {
                        // 인원 수 태그일때
                        if let _ = FilterTags.getNumberFromPeopleCountString(countString: querySet.first!) {
                            return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: querySet.first!, frameCount: "전체", filterTags: [], pageNumber: owner.currentPage)).asObservable()
                        }
                        
                        // 프레임 수 태그일때
                        if let _ = FilterTags.getNumberFromFrameCountString(countString: querySet.first!) {
                            return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: "전체", frameCount: querySet.first!, filterTags: [], pageNumber: owner.currentPage)).asObservable()
                        }
                        
                        return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: "전체", frameCount: "전체", filterTags: querySet, pageNumber: owner.currentPage)).asObservable()
                    }
                    
                    return owner.apiSession.requestSingle(.retrieveFilteringPoseFeed(peopleCount: querySet[0], frameCount: querySet[1], filterTags: filterTags, pageNumber: owner.currentPage)).asObservable()
                }
            }
            .withUnretained(self)
            .flatMapLatest { owner, filteredPose -> Observable<[PoseFeedPhotoCellViewModel]> in
                owner.isLast = filteredPose.filteredContents?.last ?? true
                recommendContents.accept(filteredPose.recommendedContents) // 2-2로 이동
                
                guard let contents = filteredPose.filteredContents?.content else { return Observable<[PoseFeedPhotoCellViewModel]>.empty() }
                
                return owner.retrieveCacheObservable(posefeed: contents)
                    .skip(while: { $0.count < contents.count })
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, filteredContents in
                owner.endLoading()
                loadable.accept(false)
                filterSection.accept(filterSection.value + filteredContents)
            })
            .disposed(by: disposeBag)
        
        /// 5. 상세 페이지 태그 tap 이후 쿼리 파라미터 새로 세팅
        input.modalDismissWithTag
            .subscribe(onNext: {
                let viewModel = RegisteredFilterCellViewModel(title: $0)
                tagItems.accept([viewModel])
                queryParameters.accept([$0])
            })
            .disposed(by: disposeBag)
        
        /// 필터 섹션 & 추천 섹션 결합 후 셀 아이템에 바인딩
        Observable.combineLatest(filterSection, recommendSection)
            .subscribe(onNext: { filter, recommend in
                let newSectionItems = [PoseSection(header: "", items: filter), PoseSection(header: "이런 포즈는 어때요?", items: recommend)]
                sectionItems.accept(newSectionItems)
            })
            .disposed(by: disposeBag)
        
        /// 6. 애플 아이덴티티 토큰 세팅 후 로그인처리
        input.appleIdentityTokenTrigger
            .flatMapLatest { [unowned self] token -> Observable<PosePickerUser> in
                return self.apiSession.requestSingle(.appleLogin(idToken: token)).asObservable()
            }
            .flatMapLatest { user -> Observable<(Void, Void, Void, Void)> in
                let accessTokenObservable = KeychainManager.shared.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = KeychainManager.shared.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                let userIdObservable = KeychainManager.shared.rx.saveItem("\(user.id)", itemClass: .password, key: K.Parameters.userId)
                let emailObservable = KeychainManager.shared.rx.saveItem(user.email, itemClass: .password, key: K.Parameters.email)
                return Observable.zip(accessTokenObservable, refreshTokenObservable, userIdObservable, emailObservable)
            }
            .subscribe(onNext: { _ in
                dismissLoginView.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 7. 카카오 이메일 추출 후 로그인처리
        input.kakaoLoginTrigger
            .flatMapLatest { [unowned self] kakaoAccount -> Observable<AuthCode> in
                kakaoAccountObservable.accept(kakaoAccount)
                return self.apiSession.requestSingle(.retrieveAuthoirzationCode).asObservable()
            }
            .flatMapLatest {
                authCodeObservable.accept($0.token)
                return Observable.combineLatest(kakaoAccountObservable.asObservable(), authCodeObservable.asObservable())
            }
            .flatMapLatest { [unowned self] (params: ((String, Int64), String)) -> Observable<PosePickerUser> in
                let (email, kakaoId) = params.0
                let authCode = params.1
                return self.apiSession.requestSingle(.kakaoLogin(authCode: authCode, email: email, kakaoId: kakaoId)).asObservable()
            }
            .flatMapLatest { user -> Observable<(Void, Void, Void, Void)> in
                let accessTokenObservable = KeychainManager.shared.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = KeychainManager.shared.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                let userIdObservable = KeychainManager.shared.rx.saveItem("\(user.id)", itemClass: .password, key: K.Parameters.userId)
                let emailObservable = KeychainManager.shared.rx.saveItem(user.email, itemClass: .password, key: K.Parameters.email)
                return Observable.zip(accessTokenObservable, refreshTokenObservable, userIdObservable, emailObservable)
            }
            .subscribe(onNext: { _ in
                dismissLoginView.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 8. 북마크 등록 API 요청
        self.bookmarkButtonTapped
            .flatMapLatest { [unowned self] poseId -> Observable<BookmarkResponse> in
                return self.apiSession.requestSingle(.registerBookmark(poseId: poseId)).asObservable()
            }
            .subscribe(onNext: { _ in
                print("등록 완료!")
            })
            .disposed(by: disposeBag)
        
        /// 9. 북마크 삭제 API 요청
        self.bookmarkRemoveButtonTapped
            .flatMapLatest { [unowned self] poseId -> Observable<BookmarkResponse> in
                return self.apiSession.requestSingle(.deleteBookmark(poseId: poseId)).asObservable()
            }
            .subscribe(onNext: { _ in
                print("삭제 완료!")
            })
            .disposed(by: disposeBag)
        
        /// 10. 북마크 뷰에서 북마크버튼 체크되었을때 섹션 아이템에 데이터 바인딩
        /// 체크된 포즈아이디 기준으로 추천섹션과 필터링 섹션 조회해서 존재하면 북마크 체크값 바인딩 진행
        input.bookmarkFromPoseId
            .subscribe(onNext: { [unowned recommendSection, unowned filterSection] poseId, bookmarkCheck in
                let filterSectionValue = filterSection.value
                if let checkedIndexInFilter = filterSectionValue.firstIndex(where: {
                    return $0.poseId.value == poseId
                }) {
                    filterSectionValue[checkedIndexInFilter].bookmarkCheck.accept(bookmarkCheck)
                    filterSection.accept(filterSectionValue)
                    return
                }
                
                let recommendSectionValue = recommendSection.value
                if let checkedIndexInRecommend = recommendSectionValue.firstIndex(where: {
                    return $0.poseId.value == poseId
                }) {
                    recommendSectionValue[checkedIndexInRecommend].bookmarkCheck.accept(bookmarkCheck)
                    recommendSection.accept(recommendSectionValue)
                    return
                }
            })
            .disposed(by: disposeBag)
        
        return Output(presentModal: input.filterButtonTapped.asDriver(), filterTagItems: tagItems.asDriver(), deleteTargetFilterTag: deleteTargetFilterTag.asDriver(), deleteTargetCountTag: deleteTargetCountTag.asDriver(), deleteSubTag: deleteSubTag.asDriver(onErrorJustReturn: ()), sectionItems: sectionItems.asObservable(), poseDetailViewPush: poseDetailViewModel.asObservable(), isLoading: loadable.asObservable(), dismissLoginView: dismissLoginView)
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
        
        // 매 요소마다 accept하여 리로딩을 자주 처리하지 말고, 한번에 몰아서 진행
        posefeed.forEach { posepick in
            ImageCache.default.retrieveImage(forKey: posepick.poseInfo.imageKey, options: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    if let image = value.image {
                        let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                        
                        isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                        
                        let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else {
                        guard let url = URL(string: posepick.poseInfo.imageKey) else { return }
                        KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                            switch downloadResult {
                            case .success(let downloadImage):
                                let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                                
                                isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
                                
//                                isFilterSection ? filterContentSizeObservable.accept(filterContentSizeObservable.value + [newSizeImage.size]) : recommendContentSizeObservable.accept(recommendContentSizeObservable.value + [newSizeImage.size])
                                
//                                isFilterSection ? self.filterContentsLoadCompleteTrigger.onNext(true) : self.filterContentsLoadCompleteTrigger.onNext(false)
                                
                                let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
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
        self.nextPageRequestTrigger.accept(.idle)
        return viewModelObservable.asObservable()
    }
    
    func searchNext() {
        self.nextPageRequestTrigger.accept(.request)
    }
}
