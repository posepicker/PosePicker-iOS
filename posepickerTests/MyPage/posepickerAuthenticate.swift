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

final class posepickerAuthenticate: XCTestCase {
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
        viewModel = MyPageViewModel()
    }
    
    /// 1. 애플로그인 버튼 탭
    /// 2. idToken 전달
    /// 3. 로그인처리
    func test_애플로그인_탭_이후_로그인처리() {
        let user = scheduler.createObserver(User?.self)
        var input = retrieveDefaultInputObservable()
        
        input.appleIdToken = scheduler.createColdObservable([
            .next(10, "test_jwt")
        ]).asObservable()
        
        let output = viewModel.transform(input: input)
        
        output.user
            .drive(user)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
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
