//
//  bookmarkTests.swift
//  posepickerTests
//
//  Created by Jun on 2023/12/05.
//

import XCTest
import Alamofire
import RxCocoa
import RxSwift
import RxTest
@testable import posepicker

final class bookmarkTests: XCTestCase {
    var disposeBag: DisposeBag!
    var sut: APISession!
    var scheduler: TestScheduler!
    var viewModel: BookMarkViewModel!
    
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
        viewModel = BookMarkViewModel(apiSession: sut) // 목업 세션 주입
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
        viewModel = nil
    }
}
