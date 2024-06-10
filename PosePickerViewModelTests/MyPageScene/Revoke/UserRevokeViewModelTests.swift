//
//  UserRevokeViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift
import RxRelay

@testable import posepicker

final class UserRevokeViewModelTests: XCTestCase {
    private var viewModel: UserRevokeViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var commonUsecase: CommonUseCase!
    private var mypageCoordinator: MyPageCoordinator!
    private var input: UserRevokeViewModel.Input!
    private var output: UserRevokeViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.commonUsecase = MockCommonUseCase()
        self.mypageCoordinator = MockMyPageCoordinator(
            UINavigationController(
                rootViewController: MyPageViewController()
            )
        )
        self.viewModel = UserRevokeViewModel(
            coordinator: self.mypageCoordinator,
            commonUseCase: self.commonUsecase
        )
        self.disposeBag = DisposeBag()
    }
    
    func test_버튼_탭_테스트() {
        self.input = UserRevokeViewModel.Input(
            revokeButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ()),
                .next(1, ()),
                .next(2, ())
            ]).asObservable(),
            revokeCancelButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            revokeReason: BehaviorRelay(value: "")
        )
        
        self.output = self.viewModel.transform(
            input: self.input, disposeBag: self.disposeBag
        )
        
        self.scheduler.start()
    }
    
    func test_회원탈퇴_완료_테스트() {
        let loadingObserver = self.scheduler.createObserver(Bool.self)
        
        self.input = UserRevokeViewModel.Input(
            revokeButtonTapEvent: .empty(),
            revokeCancelButtonTapEvent: .empty(),
            revokeReason: BehaviorRelay(value: "")
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .isLoading
            .subscribe(loadingObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUsecase.revokeCompleted.onNext(())
        })
        .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(loadingObserver.events, [
            .next(0, false),
            .next(0, false)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
