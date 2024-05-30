//
//  PoseFeedViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/4/24.
//

import XCTest
import RxSwift
import RxTest
@testable import posepicker
final class PoseFeedViewModelTests: XCTestCase {
    
    private var viewModel: PoseFeedViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: PoseFeedViewModel.Input!
    private var posefeedUseCase: PoseFeedUseCase!
    private var commonUseCase: CommonUseCase!
    private var output: PoseFeedViewModel.Output!
    private var coordinator: PoseFeedCoordinator!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.posefeedUseCase = MockPoseFeedUseCase()
        self.commonUseCase = MockCommonUseCase()
        self.coordinator = MockPoseFeedCoordinator(UINavigationController(rootViewController: PoseFeedViewController()))
        self.viewModel = PoseFeedViewModel(
            coordinator: self.coordinator,
            posefeedUseCase: self.posefeedUseCase, 
            commonUseCase: self.commonUseCase
        )
        self.disposeBag = DisposeBag()
    }
    
    func test_코디네이터_동작_테스트() {
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.scheduler.start()
    }
    
    func test_무한스크롤_이후_컨텐츠_갯수와_컨텐츠사이즈_갯수가_누적되는지 () {
        let viewDidLoadEvent = self.scheduler.createHotObservable([
            .next(0, ())
        ])
        let infiniteScrollEvent = self.scheduler.createHotObservable([
            .next(2, ())
        ])
        
        let filteredContentsCountObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentsCountObserver = self.scheduler.createObserver(Int.self)
        
        let filteredContentSizesCountObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentSizesCountObserver = self.scheduler.createObserver(Int.self)
        
        let dismissModalEventObservable = self.scheduler.createHotObservable([
            .next(1, [
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "친구"),
            ])
        ])
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent.asObservable(),
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissModalEventObservable.asObservable(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        output.contents
            .map { $0[0].items.count }
            .subscribe(filteredContentsCountObserver)
            .disposed(by: self.disposeBag)
        
        output.contents
            .map { $0[1].items.count }
            .subscribe(recommendedContentsCountObserver)
            .disposed(by: self.disposeBag)
        
        output.filteredSectionContentSizes
            .map { $0.count }
            .subscribe(filteredContentSizesCountObserver)
            .disposed(by: self.disposeBag)
        
        output.recommendedSectionContentSizes
            .map { $0.count }
            .subscribe(recommendedContentSizesCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(filteredContentsCountObserver.events, [
            .next(0, 5),    // 1. viewDidLoad 데이터 초기 세팅
            .next(1, 5),    // 2. 태그 세팅 이후 데이터
            .next(2, 10)    // 3. 무한스크롤 데이터 스택
        ])
        
        XCTAssertEqual(recommendedContentsCountObserver.events, [
            .next(0, 5),    // 1. viewDidLoad 데이터 초기 세팅
            .next(1, 5),    // 2. 태그 세팅 이후 데이터
            .next(2, 10)    // 3. 무한스크롤 데이터 스택
        ])
        
        XCTAssertEqual(filteredContentSizesCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값 방출
            .next(0, 0),    // 2. pageNumber 0번 호출
            .next(0, 5),    // 3. 0번 페이지 포즈 이미지 사이즈 갯수
            .next(1, 5),    // 4. 태그 세팅 이후 데이터
            .next(2, 10)    // 5. 1번 페이지까지 쌓인 포즈 이미지 사이즈 갯수
        ])
        
        XCTAssertEqual(recommendedContentSizesCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값 방출
            .next(0, 0),    // 2. pageNumber 0번 호출
            .next(0, 5),    // 3. 0번 페이지 포즈 이미지 사이즈 갯수
            .next(1, 5),    // 4. 태그 세팅 이후 데이터
            .next(2, 10)    // 5. 1번 페이지까지 쌓인 포즈 이미지 사이즈 갯수
        ])
    }
    
    func test_필터모달_dismiss_인원수_프레임수가_전체로_선택되었을때_안보여지는지() {
        let dismissModalEventObservable = self.scheduler.createHotObservable([
            .next(1, [
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "전체")
            ]),
            .next(2, [
                RegisteredFilterCellViewModel(title: "1인"),
                RegisteredFilterCellViewModel(title: "전체"),
            ]),
            .next(3, [
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "1컷")
            ]),
            .next(4, [
                RegisteredFilterCellViewModel(title: "1인"),
                RegisteredFilterCellViewModel(title: "1컷"),
                RegisteredFilterCellViewModel(title: "친구")
            ])
        ])
        
        let registeredTagsCountObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissModalEventObservable.asObservable(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .registeredTagItems
            .map { $0.count }
            .subscribe(registeredTagsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        /// **전체 태그는 화면에서 가려져 있어야 함**
        XCTAssertEqual(registeredTagsCountObserver.events, [
            .next(0, 0),    // 1. 초기 태그 갯수
            .next(1, 0),    // 2. 전체 & 전체 태그가 포즈피드 필터로 등록되어 있을때 (화면에는 안보임)
            .next(2, 1),    // 3. 인원 수 태그만 세팅했을 때
            .next(3, 1),    // 4. 컷 수 태그만 세팅했을 때
            .next(4, 3)     // 5. 모든 태그들이 세팅되어 있을 때 (등록된 태그들 모두 보여짐)
        ])
    }
    
    func test_필터모달_dismiss이후_API요청_이루어지는지() {
        let dismissModalEventObservable = self.scheduler.createHotObservable([
            .next(0, [
                RegisteredFilterCellViewModel(title: "이상한 태그")
            ]),
            .next(1, [
                RegisteredFilterCellViewModel(title: "1인"),
                RegisteredFilterCellViewModel(title: "1컷"),
                RegisteredFilterCellViewModel(title: "친구")
            ])
        ])
        
        let filteredContentsCountObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentsCountObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissModalEventObservable.asObservable(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: self.scheduler.createColdObservable([
                .next(0, PoseFeedPhotoCellViewModel(image: nil, poseId: 1, bookmarkCheck: true))
            ]).asObservable(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .contents
            .map { $0[0].items.count }
            .subscribe(filteredContentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.output
            .contents
            .map { $0[1].items.count }
            .subscribe(recommendedContentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(filteredContentsCountObserver.events, [
            .next(1, 5)     // 1. 태그 세팅 후 필터링 포즈 불러오는지
        ])
        
        XCTAssertEqual(recommendedContentsCountObserver.events, [
            .next(1, 5)     // 1. 태그 세팅 후 추천 포즈 불러오는지
        ])
    }
    
    func test_필터태그_탭_이벤트() {
        let registeredTagsCountObserver = self.scheduler.createObserver(Int.self)
        /// 1. 초기 태그 세팅 (친구, 가족 필터 등록)
        let dismissFilterModalObservable = self.scheduler.createColdObservable([
            .next(0, [
                RegisteredFilterCellViewModel(title: "5인+"),
                RegisteredFilterCellViewModel(title: "8컷+"),
                RegisteredFilterCellViewModel(title: "친구"),
                RegisteredFilterCellViewModel(title: "가족"),
                RegisteredFilterCellViewModel(title: "유명인"),
                RegisteredFilterCellViewModel(title: "유명컷")
            ])
        ])
        
        /// 2. 친구 태그 삭제
        let filterTagTapObservable = self.scheduler.createColdObservable([
            .next(1, RegisteredFilterCellViewModel(title: "친구")),
            .next(2, RegisteredFilterCellViewModel(title: "유명인")),
            .next(3, RegisteredFilterCellViewModel(title: "5인+")),
            .next(4, RegisteredFilterCellViewModel(title: "8컷+"))
        ])
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissFilterModalObservable.asObservable(),
            filterTagTapEvent: filterTagTapObservable.asObservable(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        /// 3. 태그 삭제 여부 검증
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .registeredTagItems
            .map { $0.count }
            .subscribe(registeredTagsCountObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(registeredTagsCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값
            .next(0, 6),    // 2. 태그 세팅 후 6개
            .next(1, 5),    // 3. 친구 태그 삭제 후 5개
            .next(2, 4),    // 4. 유명인 태그 삭제 -> 끝글자 "인" 정규식에서 걸러지는지 테스트
            .next(3, 3),    // 5. 5인+ 태그 삭제 -> suffix 두글자 "인+" 걸러지는지 테스트
            .next(4, 2)     // 6. 유명컷 태그 삭제 -> suffix 두글자 "컷+" 걸러지는지 테스트
        ])
            
    }
    
    /// 1. 포즈 디테일에서 컬렉션뷰 태그 탭 이후 dismiss
    /// 2. 전체 태그 삭제
    /// 3. 포즈 상세 뷰에서 탭 한 태그만 등록
    func test_포즈_디테일_태그_탭_이후_필터_초기화되고_포즈_요청되는지() {
        let dismissModalEventObservable = self.scheduler.createHotObservable([
            .next(0, [
                RegisteredFilterCellViewModel(title: "1인"),
                RegisteredFilterCellViewModel(title: "1컷"),
                RegisteredFilterCellViewModel(title: "친구")
            ])
        ])
        
        let registeredTagCountObserver = self.scheduler.createObserver(Int.self)
        
        let expectation = XCTestExpectation(description: "등록된 태그가 꿀잼태그라는 이름을 갖는지")
        expectation.expectedFulfillmentCount = 3
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissModalEventObservable.asObservable(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: self.scheduler.createColdObservable([
                .next(1, RegisteredFilterCellViewModel(title: "꿀잼태그")),
                .next(2, RegisteredFilterCellViewModel(title: "2인")),
                .next(3, RegisteredFilterCellViewModel(title: "4컷"))
            ]).asObservable(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .registeredTagItems
            .map { $0.count }
            .subscribe(registeredTagCountObserver)
            .disposed(by: disposeBag)
        
        self.output
            .registeredTagItems
            .subscribe(onNext: {
                if $0.contains(where: { $0.title.value == "꿀잼태그"}) ||
                    $0.contains(where: { $0.title.value == "2인"}) ||
                    $0.contains(where: { $0.title.value == "4컷"}) {
                    expectation.fulfill()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        /// 포즈 상세보기의 인원 수 & 프레임 수 로직 체크
        XCTAssertEqual(registeredTagCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값
            .next(0, 3),    // 2. 등록된 태그
            .next(1, 1),    // 3. 포즈 상세보기에서 세팅된 태그 한개
            .next(2, 1),    // 4. 인원 수 태그 삭제 및 세팅 로직 돌아가는지
            .next(3, 1)     // 5. 프레임 수 태그 삭제 및 세팅 로직 돌아가는지
        ])
        
        wait(for: [expectation], timeout: 5)
    }
    
    /// 포즈피즈에서 북마크를 탭하여 외부로 나가는 흐름이 아닌 외부에서 바인딩하는 방향성 테스트
    /// 북마크 값이 서버에 저장은 되어 있기 때문에 UI만 반영하는 식으로 구현
    func test_북마크_바인딩_테스트() {
        let bookmarkFalseToTrueObserver = self.scheduler.createObserver(Bool.self)
        let bookmarkTrueToFalseObserver = self.scheduler.createObserver(Bool.self)
        let recommendedContentsBookmarObserver = self.scheduler.createObserver(Bool.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: self.scheduler.createColdObservable([
                .next(1, 1),
                .next(2, 4),
                .next(3, 9)
            ]).asObservable(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        /// 필터링 포즈
        self.posefeedUseCase
            .feedContents
            .compactMap { $0.first }
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if let bookmarkFalseToTrueItem = $0.items.first(where: {$0.poseId.value == 1}) {
                    bookmarkFalseToTrueItem.bookmarkCheck
                        .subscribe(bookmarkFalseToTrueObserver)
                        .disposed(by: self.disposeBag)
                }
                
                if let bookmarkTrueToFalseItem = $0.items.first(where: {$0.poseId.value == 4}) {
                    bookmarkTrueToFalseItem.bookmarkCheck
                        .subscribe(bookmarkTrueToFalseObserver)
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        /// 추천 포즈
        self.posefeedUseCase
            .feedContents
            .compactMap { $0.last }
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if let bookmarkItem = $0.items.first(where: {$0.poseId.value == 9 }) {
                    bookmarkItem.bookmarkCheck
                        .subscribe(recommendedContentsBookmarObserver)
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(bookmarkFalseToTrueObserver.events, [
            .next(0, false),
            .next(1, true)
        ])
        
        XCTAssertEqual(bookmarkTrueToFalseObserver.events, [
            .next(0, true),
            .next(2, false)
        ])
        
        XCTAssertEqual(recommendedContentsBookmarObserver.events, [
            .next(0, false),
            .next(3, true)
        ])
    }
    
    /// 포즈피드 내부에서 북마크 체크
    /// API 요청 후 마이포즈로 값 바인딩 진행
    func test_북마크_체크() {
        let expectation = XCTestExpectation(description: "북마크 체크가 정상적으로 이루어졌는지")
        let bookmarkCheckValueObserver = self.scheduler.createObserver(Bool.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: self.scheduler.createColdObservable([
                .next(1, Section<PoseFeedPhotoCellViewModel>.Item(image: nil, poseId: 1, bookmarkCheck: false)),    // poseId 1번 객체 북마크 true로 체크
                .next(2, Section<PoseFeedPhotoCellViewModel>.Item(image: nil, poseId: -1, bookmarkCheck: false)),    // 잘못된 북마크 체크 case
                .next(11, Section<PoseFeedPhotoCellViewModel>.Item(image: nil, poseId: 1, bookmarkCheck: true)),      // 로그아웃 이후 북마크 체크 테스트 (애플로그인)
                .next(14, Section<PoseFeedPhotoCellViewModel>.Item(image: nil, poseId: 1, bookmarkCheck: true)),       // 로그아웃 이후 북마크 체크 테스트 (카카오로그인)
                .next(16, Section<PoseFeedPhotoCellViewModel>.Item(image: nil, poseId: 1, bookmarkCheck: true))       // 로그아웃 이후 북마크 체크 테스트 (잘못된 로그인 요청 케이스 (.none 케이스)
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        
        /// 1. 로그인 된 이후 북마크 체크 테스트
        self.scheduler
            .createColdObservable([
                .next(0, ())
            ])
            .subscribe(onNext: {
                UserDefaults.standard.setValue(true, forKey: K.SocialLogin.isLoggedIn)
            })
            .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .bookmarkTaskCompleted
            .subscribe(onNext: {
                if $0 {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .feedContents
            .compactMap { $0.first?.items }
            .compactMap { $0.first(where: { $0.poseId.value == 1 })}
            .flatMapLatest { $0.bookmarkCheck }
            .subscribe(bookmarkCheckValueObserver)
            .disposed(by: disposeBag)
        
        /// 2. 로그아웃 상태의 북마크 체크 테스트
        /// 애플로그인 먼저 테스트 하고 카카오 로그인 테스트
        self.scheduler
            .createColdObservable([
                .next(10, ())
            ])
            .subscribe(onNext: {
                UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
            })
            .disposed(by: disposeBag)
        
        self.scheduler
            .createColdObservable([
                .next(13, ()),
                .next(15, ())
            ])
            .subscribe(onNext: { [weak self] in
                self?.coordinator.start() // 애플 로그인으로 소셜 로그인 상태 전환
            })
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(bookmarkCheckValueObserver.events, [
            .next(0, false),
            .next(1, true)
        ])
    }
    
    func test_리프레시_컨트롤_이벤트() {
        let infiniteScrollEvent = self.scheduler.createHotObservable([
            .next(2, ())
        ])
        let dismissModalEventObservable = self.scheduler.createHotObservable([
            .next(1, [
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "전체"),
                RegisteredFilterCellViewModel(title: "친구"),
            ])
        ])
        
        let contentsCountObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: dismissModalEventObservable.asObservable(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: self.scheduler.createColdObservable([
                .next(3, ())
            ]).asObservable(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.posefeedUseCase
            .feedContents
            .compactMap { $0.first }
            .map { $0.items.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 5),    // 1. 초기 요청 후 데이터 세팅
            .next(1, 5),    // 2. 필터 세팅 후 데이터
            .next(2, 10),   // 3. 무한 스크롤로 다음 페이지 데이터 요청
            .next(3, 5)     // 4. 새로고침 하면 1페이지 데이터로 갯수 초기화
        ])
    }
    
    func test_로그인_완료_이후_데이터_새로고침_되는지() {
        let infiniteScrollEvent = self.scheduler.createHotObservable([
            .next(1, ())
        ])
        
        let contentsCountObserver = self.scheduler.createObserver(Int.self)
        let viewDidLoadEvent = PublishSubject<Void>()
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.posefeedUseCase
            .feedContents
            .compactMap { $0.first }
            .map { $0.items.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        /// 1. 초기 데이터 요청
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: {
            viewDidLoadEvent.onNext(())
        })
        .disposed(by: disposeBag)
        
        /// 2. 로그인 완료
        self.scheduler.createColdObservable([
            .next(3, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.loginWithApple()
        })
        .disposed(by: disposeBag)
        
        /// 3. 유스케이스에서 로그인 완료 여부 확인 -> viewDidLoad 한번 더 트리거 / 기본 output 로직
        self.output
            .refreshEvent
            .subscribe(onNext: {
                viewDidLoadEvent.onNext(())
            })
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 5),    // 1. 초기 요청 후 데이터
            .next(1, 10),   // 2. 무한스크롤 다음 페이지 데이터 요청 후 쌓인 갯수
            .next(3, 5)     // 3. 로그인 or 로그아웃 후 새로고침 된 이후 데이터 갯수
        ])
    }
    
    func test_포즈_업로드_버튼_탭() {
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: .empty(),
            infiniteScrollEvent: .empty(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: self.scheduler.createColdObservable([
                .next(1, ()),
                .next(5, ()),
                .next(7, ()),
                .next(9, ()),
            ]).asObservable(),
            refreshEvent: .empty(),
            bookmarkButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        /// time 0 : 로그인 상태
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: {
            UserDefaults.standard.setValue(true, forKey: K.SocialLogin.isLoggedIn)
        })
        .disposed(by: disposeBag)
        
        /// time 4: 로그아웃 상태
        self.scheduler.createColdObservable([
            .next(4, ())
        ])
        .subscribe(onNext: {
            UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
        })
        .disposed(by: disposeBag)
        
        self.scheduler
            .createColdObservable([
                .next(6, ()),
                .next(8, ())
            ])
            .subscribe(onNext: { [weak self] in
                self?.coordinator.start() // 애플 로그인으로 소셜 로그인 상태 전환
            })
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.posefeedUseCase = nil
        self.output = nil
        UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
    }
}
