//
//  CommonSceneUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/2/24.
//

import XCTest
import RxTest
import RxSwift
@testable import posepicker

final class CommonSceneUseCaseTests: XCTestCase {

    private let disposeBag = DisposeBag()
    private var userRepository: UserRepository!
    private var commonUseCase: CommonUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.userRepository = MockUserRepository()
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        self.scheduler = TestScheduler(initialClock: 0)
    }
    
//    func logout(with: LoginPopUpView.SocialLogin)
//    func revoke(with: LoginPopUpView.SocialLogin, reason: String)
    
    func test_카카오_로그인_완료_테스트() {
        let expectation = XCTestExpectation(description: "login completed test")
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.loginWithKakao()
        })
        .disposed(by: self.disposeBag)
        
        self.commonUseCase.loginCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_애플_로그인_완료_테스트() {
        let expectation = XCTestExpectation(description: "login completed test")
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.loginWithApple(idToken: "apple id token")
        })
        .disposed(by: self.disposeBag)
        
        self.commonUseCase.loginCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_로그아웃_테스트() {
        let expectation = XCTestExpectation(description: "logout completed test")
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.logout(with: .kakao)
        })
        .disposed(by: self.disposeBag)
        
        self.commonUseCase.logoutCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        self.userRepository = nil
        self.commonUseCase = nil
        self.scheduler = nil
    }

}
