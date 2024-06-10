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
        self.mockPageViewCoordinator = MockPageViewCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.mockPageViewCoordinator.start()
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
        // MARK: - 뷰 컨트롤러의 페이지뷰 데이터소스에 대한 접근 권한을 테스트코드에서 얻어올 수 없어서 작성 한계
         let pageviewTransitionDelegateEvent = self.scheduler.createHotObservable([
             .next(1, ()),
             .next(2, ())
         ])
        
         let mypageButtonTapped: TestableObservable<Void> = self.scheduler.createColdObservable([
            .next(0, ())
         ])
        
         let currentPage = self.scheduler.createHotObservable([
             .next(1, 1)
         ])
        
        let bookmarkButtonTapObservable = self.scheduler.createColdObservable([
            .next(2, ()),
            .next(3, ()),
            .next(4, ())
        ])
        
        
         self.input = CommonViewModel.Input(
             pageviewTransitionDelegateEvent: pageviewTransitionDelegateEvent.asObservable(),
             myPageButtonTapEvent: mypageButtonTapped.asObservable(),
             currentPage: currentPage.asObservable(),
             bookmarkButtonTapEvent: bookmarkButtonTapObservable.asObservable(),
             removeMyPoseContentsEvent: self.scheduler.createColdObservable([
                .next(0, ())
             ]).asObservable()
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
             .next(1, 0),
             .next(2, 1)
         ])
    }
    
    func test_로그인_되지_않은_상태에서_마이포즈_접근_로직_테스트() {
        // MARK: - Observers
        let pageTransitionObservers = self.scheduler.createObserver(Int.self)
        
        // MARK: - Test Config
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: {
            UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
        })
        .disposed(by: self.disposeBag)
        
        self.scheduler.createColdObservable([
            .next(4, ())
        ])
        .subscribe(onNext: {
            UserDefaults.standard.setValue(true, forKey: K.SocialLogin.isLoggedIn)
        })
        .disposed(by: self.disposeBag)
        
        /// 로그인 완료 이후 세팅되어 있는 페이지값 출력
        self.scheduler.createColdObservable([
            .next(6, ())
        ])
        .subscribe(onNext: { [weak self] in
            guard let self = self,
                  let coordinator = self.viewModel.coordinator else { return }
            pageTransitionObservers.onNext(coordinator.currentPage().pageOrderNumber())
        })
        .disposed(by: self.disposeBag)
        
        // MARK: - Observables
        let currentPage = self.scheduler.createHotObservable([
            .next(1, 3),     // 로그인 하지 않은 채로 마이포즈 접근 시도
            .next(1, 2),
            .next(2, 3),     // 애플로그인, 카카오 로그인, none switch-case 검증
            .next(3, 3),     // 로그인 완료 이후 시나리오 테스트
            .next(5, 3)
        ])
        
        // MARK: - Input & Output
        self.input = CommonViewModel.Input(
            pageviewTransitionDelegateEvent: .empty(),
            myPageButtonTapEvent: .empty(),
            currentPage: currentPage.asObservable(),
            bookmarkButtonTapEvent: .empty(),
            removeMyPoseContentsEvent: .empty()
        )
       
        self.output = self.viewModel.transform(from: self.input, disposeBag: self.disposeBag)
        
        self.output
            .pageTransitionEvent
            .subscribe(pageTransitionObservers)
            .disposed(by: self.disposeBag)
        
        _ = self.viewModel.viewControllerAfter()
        _ = self.viewModel.viewControllerBefore()
        
        self.scheduler.start()
        
        XCTAssertEqual(pageTransitionObservers.events, [
            .next(1, 0),
            .next(2, 0),
            .next(3, 0),
            .next(6, 3)
        ])
        
    }

    override func tearDown() {
        super.tearDown()
        self.mockPageViewCoordinator = nil
        self.commonUseCase = nil
        self.viewModel = nil
        self.scheduler = nil
        self.disposeBag = nil
        self.input = nil
        self.output = nil
    }
}
