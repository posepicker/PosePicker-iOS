//
//  CommonViewTest.swift
//  posepickerTests
//
//  Created by 박경준 on 3/28/24.
//

import XCTest
import RxSwift
import RxTest

@testable import posepicker

final class CommonViewTest: XCTestCase {
    
    private var mockPageViewCoordinator: MockPageViewCoordinator!
    private var commonUseCase: CommonUseCase!
    private var viewModel: CommonViewModel!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    private var input: CommonViewModel.Input!
    private var output: CommonViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.mockPageViewCoordinator = MockPageViewCoordinator(UINavigationController())
        self.commonUseCase = MockCommonUseCase()
        self.viewModel = CommonViewModel(
            coordinator: self.mockPageViewCoordinator,
            commonUseCase: self.commonUseCase
        )
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func test_페이지뷰_델리게이트_호출이후_인덱스값_방출이_이루어지는지() {
        // MARK: - 코디네이터 주입이 되지 않으면 화면 간 데이터 주고받는 로직 테스트가 불가능
        // MARK: - 목업 코디네이터 주입 필요
        // 테스트 코드 작성이 어려움.
         let pageviewTransitionDelegateEvent = self.scheduler.createHotObservable([
             .next(1, ())
         ])
         let mypageButtonTapped: TestableObservable<Void> = self.scheduler.createHotObservable([])
         let currentPage = self.scheduler.createHotObservable([
             .next(1, 1)
         ])
        
         self.input = CommonViewModel.Input(
             pageviewTransitionDelegateEvent: pageviewTransitionDelegateEvent.asObservable(),
             myPageButtonTapped: mypageButtonTapped.asObservable(),
             currentPage: currentPage.asObservable()
         )
        
         self.output = self.viewModel.transform(
             from: self.input,
             disposeBag: self.disposeBag
         )
        
         let pageTransitionEvent = self.scheduler.createObserver(Int.self)
        
         output.pageTransitionEvent
             .subscribe(pageTransitionEvent)
             .disposed(by: self.disposeBag)
        
         self.scheduler.start()
        
         XCTAssertEqual(pageTransitionEvent.events, [
             .next(1, 1)
         ])
    }

    override func tearDown() {
        
    }
}
