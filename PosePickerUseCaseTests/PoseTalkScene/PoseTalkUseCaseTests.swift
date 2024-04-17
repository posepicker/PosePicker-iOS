//
//  PoseTalkUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/17/24.
//

import UIKit
import XCTest
import Alamofire
import RxSwift
import RxCocoa
import RxTest
import Kingfisher
@testable import posepicker

final class PoseTalkUseCaseTests: XCTestCase {

    private var disposeBag = DisposeBag()
    private var posetalkRespository: PoseTalkRepository!
    private var posetalkUseCase: PoseTalkUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.posetalkRespository = MockPoseTalkRepository()
        self.posetalkUseCase = DefaultPoseTalkUseCase(posetalkRepository: self.posetalkRespository)
        self.scheduler = .init(initialClock: 0)
    }
    
    func test_포즈톡_데이터_불러오기_테스트() {
        let expectation = XCTestExpectation(description: "포즈톡 데이터 불러오기 동작 테스트")
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: {
            self.posetalkUseCase
                .fetchPoseTalk()
        })
        .disposed(by: self.disposeBag)
        
        self.posetalkUseCase
            .poseWord
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.posetalkUseCase = nil
        self.posetalkRespository = nil
        self.scheduler = nil
    }
}
