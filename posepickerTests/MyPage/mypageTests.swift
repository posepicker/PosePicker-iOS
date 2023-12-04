//
//  posepickerAuthenticate.swift
//  posepickerTests
//
//  Created by Jun on 2023/12/04.
//

import XCTest
import Alamofire
import RxCocoa
import RxSwift
import RxTest
@testable import posepicker

final class MyPageTests: XCTestCase {
    var disposeBag: DisposeBag!
    var sut: APISession!
    var scheduler: TestScheduler!
    var viewModel: MyPageViewModel!
    
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
        sut = APISession(session: session)
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = MyPageViewModel(apiSession: sut) // 목업 세션 주입
    }
    
    /// Given - 애플 아이디 토큰
    /// When - apiSession 객체를 통해 토큰 요청
    /// Then - 토큰 발급 후 액세스토큰 & 리프레시 토큰 추출
    func test_애플로그인_탭_이후_로그인처리() {
        MockURLProtocol.responseWithDTO(type: .user)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        let expectation = XCTestExpectation(description: "/api/users/login/apple/ 테스트")
        var input = retrieveDefaultInputObservable()
        
        input.appleIdToken = scheduler.createColdObservable([
            .next(10, "test_idToken")
        ]).asObservable()
        
        let output = viewModel.transform(input: input)
        
        // 액세스 토큰 세팅
        output.user.asObservable()
            .compactMap { $0 }
            .map { $0.token }
            .subscribe(onNext: {
                print("세팅된 TOKEN: \($0)")
                XCTAssertEqual($0.accessToken, "string")
                XCTAssertEqual($0.refreshToken, "string")
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
        viewModel = nil
    }
    
    func retrieveDefaultInputObservable() -> MyPageViewModel.Input {
        let appleIdObservable: TestableObservable<String> = scheduler.createColdObservable([])
        let inputObservable = MyPageViewModel.Input(appleIdToken: appleIdObservable.asObservable())
        
        return inputObservable
    }
}
