//
//  MyPageViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class MyPageViewModelTests: XCTestCase {
    private var viewModel: MyPageViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var commonUsecase: CommonUseCase!
    private var mypageCoordinator: MyPageCoordinator!
    private var input: MyPageViewModel.Input!
    private var output: MyPageViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.commonUsecase = MockCommonUseCase()
        self.mypageCoordinator = MockMyPageCoordinator(
            UINavigationController(
                rootViewController: MyPageViewController()
            )
        )
        self.viewModel = MyPageViewModel(
            coordinator: self.mypageCoordinator,
            commonUseCase: self.commonUsecase
        )
        self.disposeBag = DisposeBag()
    }
    
    func test_화면_push_함수_호출_테스트() {
        // MARK: - Expectations
        let expectation = XCTestExpectation(description: "회원탈퇴 완료 테스트")
        
        // MARK: - Test Observers
        let loginStateObserver = self.scheduler.createObserver(Bool.self)
        
        // MARK: - Test Observables
        let coordinatorTriggerObservable = self.scheduler.createColdObservable([
            .next(0, ())
        ]).asObservable()
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUsecase.logoutCompleted.onNext(())
            self?.commonUsecase.revokeCompleted.onNext(())
        })
        .disposed(by: self.disposeBag)
        
        self.input = MyPageViewModel.Input(
            noticeButtonTapEvent: coordinatorTriggerObservable,
            faqButtonTapEvent: coordinatorTriggerObservable,
            snsButtonTapEvent: coordinatorTriggerObservable,
            serviceInquiryButtonTapEvent: coordinatorTriggerObservable,
            serviceInformationButtonTapEvent: coordinatorTriggerObservable,
            privacyInformationButtonTapEvent: coordinatorTriggerObservable,
            logoutButtonTapEvent: .empty(),
            signoutButtonTapEvent: .empty(),
            loginButtonTapEvent: .empty()
        )
        
        self.output = self.viewModel.transform(
            input: self.input, disposeBag: self.disposeBag
        )
        
        self.output
            .refreshLoginState
            .subscribe(loginStateObserver)
            .disposed(by: self.disposeBag)
        
        self.commonUsecase
            .revokeCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
            
        self.scheduler.start()
        
        XCTAssertEqual(loginStateObserver.events, [
            .next(0, false)
        ])
        
        wait(for: [expectation])
    }
    
    func test_버튼_탭_테스트() {
        self.input = MyPageViewModel.Input(
            noticeButtonTapEvent: .empty(),
            faqButtonTapEvent: .empty(),
            snsButtonTapEvent: .empty(),
            serviceInquiryButtonTapEvent: .empty(),
            serviceInformationButtonTapEvent: .empty(),
            privacyInformationButtonTapEvent: .empty(),
            logoutButtonTapEvent: self.scheduler.createColdObservable([
                .next(3, ())
            ]).asObservable(),
            signoutButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            loginButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ()),
                .next(1, ()),
                .next(2, ()),
                .next(5, ())
            ]).asObservable()
        )
            
        // MARK: - 마이페이지 코디네이터 로그인 델리게이트 초기화
        self.scheduler.createColdObservable([
            .next(4, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.mypageCoordinator.loginDelegate = nil
        })
        .disposed(by: self.disposeBag)
        
        self.output = self.viewModel.transform(
            input: self.input, disposeBag: self.disposeBag
        )
        
        self.scheduler.start()
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.commonUsecase = nil
        self.mypageCoordinator = nil
        self.scheduler = nil
        self.input = nil
        self.output = nil
    }
}
