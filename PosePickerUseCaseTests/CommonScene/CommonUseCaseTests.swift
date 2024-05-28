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
    
    func test_로그아웃_에러테스트() {
        let expectation = XCTestExpectation(description: "logout error test")
        
        self.userRepository = MockUserRepository(errorWithLogout: true)
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        
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
    
    func test_로그아웃_401_테스트() {
        let expectation = XCTestExpectation(description: "logout error test")
        
        self.userRepository = MockUserRepository(errorWithLogout: false, expiredWithLogout: true)
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        
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
    
    func test_회원탈퇴_테스트() {
        let expectation = XCTestExpectation(description: "revoke test")
        
        self.userRepository = MockUserRepository()
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.revoke(with: .kakao, reason: "회원탈퇴")
        })
        .disposed(by: self.disposeBag)
        
        self.commonUseCase.revokeCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_회원탈퇴_에러테스트() {
        let expectation = XCTestExpectation(description: "revoke 500 error test")
        
        self.userRepository = MockUserRepository(errorWithDeleteUser: true)
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.commonUseCase.revoke(with: .kakao, reason: "회원탈퇴")
        })
        .disposed(by: self.disposeBag)
        
        self.commonUseCase.revokeCompleted
            .subscribe(onNext: {
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
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
