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
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.posefeedUseCase = MockPoseFeedUseCase()
        self.viewModel = PoseFeedViewModel(
            coordinator: nil,
            posefeedUseCase: self.posefeedUseCase
        )
        self.disposeBag = DisposeBag()
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
            filterButtonTapEvent: Observable<Void>.empty()
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
            .next(0, 0),
            .next(0, 5),
            .next(1, 10)
        ])
        
        XCTAssertEqual(recommendedContentSizesCountObserver.events, [
            .next(0, 0),
            .next(0, 5),
            .next(1, 10)
        ])
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
