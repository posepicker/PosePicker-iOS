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
    private var output: PoseFeedViewModel.Output!
    private var coordinator: PoseFeedCoordinator!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.posefeedUseCase = MockPoseFeedUseCase()
        self.coordinator = MockPoseFeedCoordinator(UINavigationController(rootViewController: PoseFeedViewController()))
        self.viewModel = PoseFeedViewModel(
            coordinator: self.coordinator,
            posefeedUseCase: self.posefeedUseCase, 
            commonUseCase: DefaultCommonUseCase(
                userRepository: DefaultUserRepository(
                    networkService: DefaultNetworkService(),
                    keychainService: DefaultKeychainService()
                )
            )
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
            refreshEvent: .empty()
        )
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.scheduler.start()
    }
    
    func test_무한스크롤_이후_컨텐츠_갯수와_컨텐츠사이즈_갯수가_누적되는지 () {
        let viewDidLoadEvent = self.scheduler.createHotObservable([
            .next(0, ())
        ])
        let infiniteScrollEvent = self.scheduler.createHotObservable([
            .next(1, ())
        ])
        
        let filteredContentsCountObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentsCountObserver = self.scheduler.createObserver(Int.self)
        
        let filteredContentSizesCountObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentSizesCountObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseFeedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent.asObservable(),
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            filterButtonTapEvent: .empty(),
            dismissFilterModalEvent: .empty(),
            filterTagTapEvent: .empty(),
            posefeedPhotoCellTapEvent: .empty(),
            dismissPoseDetailEvent: .empty(),
            bookmarkBindingEvent: .empty(),
            poseUploadButtonTapEvent: .empty(),
            refreshEvent: .empty()
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
            .next(0, 5),
            .next(1, 10)
        ])
        
        XCTAssertEqual(recommendedContentsCountObserver.events, [
            .next(0, 5),
            .next(1, 10)
        ])
        
        XCTAssertEqual(filteredContentSizesCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값 방출
            .next(0, 0),    // 2. pageNumber 0번 호출
            .next(0, 5),    // 3. 0번 페이지 포즈 이미지 사이즈 갯수
            .next(1, 10)    // 4. 1번 페이지까지 쌓인 포즈 이미지 사이즈 갯수
        ])
        
        XCTAssertEqual(recommendedContentSizesCountObserver.events, [
            .next(0, 0),    // 1. BehaviorRelay 초기값 방출
            .next(0, 0),    // 2. pageNumber 0번 호출
            .next(0, 5),    // 3. 0번 페이지 포즈 이미지 사이즈 갯수
            .next(1, 10)    // 4. 1번 페이지까지 쌓인 포즈 이미지 사이즈 갯수
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
            refreshEvent: .empty()
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
            refreshEvent: .empty()
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
            refreshEvent: .empty()
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
            refreshEvent: .empty()
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
            refreshEvent: .empty()
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
            refreshEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.posefeedUseCase = nil
        self.output = nil
    }
}
