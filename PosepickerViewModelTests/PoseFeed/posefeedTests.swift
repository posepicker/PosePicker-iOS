//
//  posefeedTests.swift
//  posepicker
//
//  Created by 박경준 on 12/4/23.
//

@testable import posepicker
import XCTest
import Alamofire
import RxCocoa
import RxSwift


final class posefeedTests: XCTestCase {
    
    var sut: APISession!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        let session: Session = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [MockURLProtocol.self] // 내가만든 가짜 프로토콜 주입!
                return configuration
            }()
            return Session(configuration: configuration)
        }()
        sut = APISession(session: session)
        disposeBag = DisposeBag()
    }

    func test_api_pose_id() {
        MockURLProtocol.responseWithDTO(type: .posepick)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        let expectation = XCTestExpectation(description: "포즈픽 /api/pose/{id} 테스트")
        let single: Single<PosePick> = sut.requestSingle(.retrievePoseDetail(poseId: 460))
        
        single.asObservable()
            .subscribe(onNext: {
                XCTAssertEqual($0.poseInfo.poseId, 460)
                print($0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        disposeBag = nil
    }
}
