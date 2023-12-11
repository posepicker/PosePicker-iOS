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
    
    override func setUp() {
        super.setUp()
//        let session: Session = {
//            let configuration: URLSessionConfiguration = {
//                let configuration = URLSessionConfiguration.default
//                configuration.protocolClasses = [MockURLProtocol.self]
//                return configuration
//            }()
//            return Session(configuration: configuration)
//        }()
//        sut = APISession(session: session)
        sut = APISession()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    func test_카카오_로그인() {
        let authCode = scheduler.createObserver(String.self)
        
        let trigger = scheduler.createColdObservable([
            .next(10, ())
        ])
        
        let expectation = XCTestExpectation(description: "유효성 검사 토큰 API 테스트")
        
        trigger
            .flatMapLatest { [unowned self] _ -> Single<String> in
                return sut.requestSingle(.retrieveAuthoirzationCode)
            }
            .subscribe(onNext: {
                print($0)
                expectation.fulfill()
            }, onError: {
                print("ERROR")
                print($0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
}
