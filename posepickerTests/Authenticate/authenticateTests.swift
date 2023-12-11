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
    
    struct AuthCode: Codable {
        let code: String
    }
    
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
                return self.sut.requestSingle(.kakaoLogin(authCode: authCode.code, email: "rudwns3927@gmail.com", kakaoId: 1)).asObservable()
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
    
    override func tearDown() {
        super.tearDown()
        
        disposeBag = nil
        sut = nil
        scheduler = nil
        keychainManager = nil
    }
}
