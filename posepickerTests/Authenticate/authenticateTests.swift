//
//  authenticateTests.swift
//  posepickerTests
//
//  Created by 박경준 on 12/11/23.
//

import XCTest
import Alamofire
import RxCocoa
import RxSwift
import RxTest
@testable import posepicker

final class authenticateTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var sut: APISession!
    var scheduler: TestScheduler!
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        
        let session: Session = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [MockURLProtocol.self]
                return configuration
            }()
            return Session(configuration: configuration)
        }()
        
        disposeBag = DisposeBag()
        sut = APISession(session: session)
        keychainManager = KeychainManager.mock
        scheduler = TestScheduler(initialClock: 0)
    }
    
    func test_카카오_토큰발급_과정() {
        MockURLProtocol.responseWithDTO(type: .authorizationCode)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        let jwtExpectation = XCTestExpectation(description: "포즈피커 JWT 유효성 검사 토큰 API")
        let kakaoExpectation = XCTestExpectation(description: "카카오 로그인 API")
        
        let loginButtonTapped = scheduler.createColdObservable([
            .next(10, ())
        ])
        
        loginButtonTapped
            .flatMapLatest { [unowned self] _ -> Observable<AuthCode> in
                return self.sut.requestSingle(.retrieveAuthoirzationCode).asObservable()
            }
            .flatMapLatest { authCode -> Observable<User> in
                MockURLProtocol.responseWithDTO(type: .user)
                return self.sut.requestSingle(.kakaoLogin(authCode: authCode.token, email: "rudwns3927@gmail.com", kakaoId: 1)).asObservable()
            }
            .flatMapLatest { [unowned self] user -> Observable<(Void, Void)> in
                let accessTokenObservable = self.keychainManager.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = self.keychainManager.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                return Observable.combineLatest(accessTokenObservable, refreshTokenObservable)
            }
            .subscribe(onNext: { _ in
                jwtExpectation.fulfill()
                kakaoExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [jwtExpectation, kakaoExpectation], timeout: 5)
    }
    
    func test_401에러후_updateItem_정상동작_검증() {
        
    }
    
    func test_애플로그인() {
        MockURLProtocol.responseWithDTO(type: .user)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        let expectation = XCTestExpectation(description: "애플로그인 테스트")
        
        let loginButtonTapped = scheduler.createColdObservable([
            .next(10, "eyJraWQiOiJZdXlYb1kiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnBhcmtqanUucG9zZXBpY2tlciIsImV4cCI6MTcwMjMwMzQyNSwiaWF0IjoxNzAyMjE3MDI1LCJzdWIiOiIwMDE2OTQuYWZhNDU3NjVkODkzNGZiMzhjMmI2MDZmNTZiMGNlMTguMTQ1MyIsImNfaGFzaCI6ImpFODEtYUMweWUtSS1UNkJMLVVWTHciLCJlbWFpbCI6InJ1ZHduczM5MjdAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOiJ0cnVlIiwiYXV0aF90aW1lIjoxNzAyMjE3MDI1LCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.nRY-EUsAZOOod8bNuBqG51WUorI1wa9w4gLk581px3WR4I13_091CzWY8Q6DkvvicFI0hOTpHAyp6mGblcAE2-1UV8nMHzer70zqzMkvSqcnB1WiTlxVnlic5K7I66EPJDkhxagCYZsaYZ4APavOWtrjO16i-M6hm2LKo-8KyfP-SslUobJz33tUxnlfSr2wokndGK0wrrKBK_mEnadw8SMm2Xa9g5mmT1We4JCLX5RMzQHdB27G3MieJemso3lQ3NBEa7EY8hGofKgHUN2NGXhqeOuSUZPfadVMO2zblBNvCu8k2Wsd-Xnwk5uHYyc10vqsv3Nk-5Iwe2xQA60pxw")
        ])
        
        loginButtonTapped
            .flatMapLatest { [unowned self] token -> Observable<User> in
                return sut.requestSingle(.appleLogin(idToken: token)).asObservable()
            }
            .flatMapLatest { [unowned self] user -> Observable<(Void, Void)> in
                let accessTokenObservable = self.keychainManager.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = self.keychainManager.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                return Observable.combineLatest(accessTokenObservable, refreshTokenObservable)
            }
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        scheduler.start()
    }
    
    override func tearDown() {
        super.tearDown()
        
        disposeBag = nil
        sut = nil
        scheduler = nil
        keychainManager = nil
    }
}
