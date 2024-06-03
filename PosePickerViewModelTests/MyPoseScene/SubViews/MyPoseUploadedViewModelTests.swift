//
//  MyPoseUploadedViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/3/24.
//

import XCTest
import RxTest
import RxSwift
@testable import posepicker

final class MyPoseUploadedViewModelTests: XCTestCase {
    
    private var viewModel: MyPoseUploadedViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: MyPoseUploadedViewModel.Input!
    private var myPoseUsecase: MyPoseUseCase!
    private var output: MyPoseUploadedViewModel.Output!
    private var myposeCoordinator: MyPoseCoordinator!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.myPoseUsecase = MockMyPoseUseCase()
        self.myposeCoordinator = MockMyPoseCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.viewModel = MyPoseUploadedViewModel(
            coordinator: self.myposeCoordinator,
            myPoseUseCase: self.myPoseUsecase
        )
    }
    
    func test_데이터_무한스크롤_데이터_누적_테스트() {
        // MARK: - Test Observer
        let infiniteScrollEvent = self.scheduler.createColdObservable([
            .next(2, ())
        ])
        
        let contentsCountObserver = self.scheduler.createObserver(Int.self)
        let contentsSizesCountObserver = self.scheduler.createObserver(Int.self)
        
        // MARK: - Input & Output
        self.input = MyPoseUploadedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(1, ())
            ]).asObservable(),
            bookmarkCellTapEvent: self.scheduler.createColdObservable([
                .next(0, .init(image: nil, poseId: 0, bookmarkCheck: false))
            ]).asObservable(),
            bookmarkButtonTapEvent: .empty(),
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            contentsUpdateEvent: .empty(),
            refreshEvent: .empty(),
            removeAllContentsEvent: self.scheduler.createColdObservable([
                .next(5, ())
            ]).asObservable(),
            poseUploadButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        self.output
            .uploadedContents
            .map { $0.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.output
            .uploadedContentSizes
            .map { $0.count }
            .subscribe(contentsSizesCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 0),
            .next(1, 5),
            .next(2, 10),
            .next(5, 0)
        ])
        
        XCTAssertEqual(contentsSizesCountObserver.events, [
            .next(0, 0),
            .next(1, 5),
            .next(2, 10),
            .next(5, 0)
        ])
    }
    
    func test_북마크_탭_테스트() {
        // MARK: - Test Observers
        let bookmarkCheckObserver = self.scheduler.createObserver(Bool.self)
        
        // MARK: - Input & Output
        self.input = MyPoseUploadedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(1, ())
            ]).asObservable(),
            bookmarkCellTapEvent: .empty(),
            bookmarkButtonTapEvent: self.scheduler.createColdObservable([
                .next(2, (1, false)),   // 북마크 체크
                .next(3, (4, true)),
                .next(4, (-1, false))   // 북마크 비정상 체크
            ]).asObservable(),
            infiniteScrollEvent: .empty(),
            contentsUpdateEvent: .empty(),
            refreshEvent: .empty(),
            removeAllContentsEvent: .empty(),
            poseUploadButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        // 북마크 탭 인풋에 대한 정상처리 테스트
        self.myPoseUsecase
            .bookmarkTaskCompleted
            .subscribe(bookmarkCheckObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(bookmarkCheckObserver.events, [
            .next(2, true),
            .next(3, true),
            .next(4, false)
        ])
    }
    
    /// **Scenario1: 외부에서 북마크 컨텐츠 업데이트가 이루어졌을때 북마크 뷰 컨트롤러 북마크 컨텐츠 전체 새로고침**
    /// **Scenario2: 당겨서 새로고침이 이루어졌을 때 북마크 컨텐츠 전체 새로고침**
    func test_새로고침과_컨텐츠_업데이트_테스트() {
        // MARK: - Test Observer
        let infiniteScrollEvent = self.scheduler.createColdObservable([
            .next(1, ()),
            .next(3, ())
        ])
        
        let contentsCountObserver = self.scheduler.createObserver(Int.self)
        let contentsSizesCountObserver = self.scheduler.createObserver(Int.self)
        
        // MARK: - Input & Output
        self.input = MyPoseUploadedViewModel.Input(
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            bookmarkCellTapEvent: .empty(),
            bookmarkButtonTapEvent: .empty(),
            infiniteScrollEvent: infiniteScrollEvent.asObservable(),
            contentsUpdateEvent: self.scheduler.createColdObservable([
                .next(4, ())
            ]).asObservable(),
            refreshEvent: self.scheduler.createColdObservable([
                .next(2, ())
            ]).asObservable(),
            removeAllContentsEvent: .empty(),
            poseUploadButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        self.output
            .uploadedContents
            .map { $0.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.output
            .uploadedContentSizes
            .map { $0.count }
            .subscribe(contentsSizesCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 0),
            .next(0, 5),
            .next(1, 10),
            .next(2, 5),
            .next(3, 10),
            .next(4, 5)
        ])
        
        XCTAssertEqual(contentsSizesCountObserver.events, [
            .next(0, 0),
            .next(0, 5),
            .next(1, 10),
            .next(2, 5),
            .next(3, 10),
            .next(4, 5)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.myPoseUsecase = nil
        self.output = nil
    }
}
