//
//  PosePickUseCaseTests.swift
//  posepickerTests
//
//  Created by 박경준 on 3/31/24.
//

import UIKit
import XCTest
import Alamofire
import RxSwift
import RxCocoa
import RxTest
import Kingfisher
@testable import posepicker

final class PosePickUseCaseTests: XCTestCase {

    private let disposeBag = DisposeBag()
    private var posepickRespository: PosePickRepository!
    private var posepickUseCase: PosePickUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        let imageDownloader: ImageDownloader = {
            let downloader = ImageDownloader.default
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockURLProtocol.self]
            downloader.sessionConfiguration = configuration
            return downloader
        }()
        
        self.posepickRespository = MockPosePickRepository(imageDownloader: imageDownloader)
        self.posepickUseCase = DefaultPosePickUseCase(
            posepickRepository: self.posepickRespository
        )
        self.scheduler = .init(initialClock: 0)
        
        ImageCache.default.clearCache()
    }
    
    func test_디스크_캐싱_처리가_잘_되는지 (){
        let expectation = XCTestExpectation(description: "포즈픽 유스케이스 데이터 잘 불러오는지")
        
        MockURLProtocol.responseWithStatusCode(code: 200)
        MockURLProtocol.responseWithDTO(type: .cacheImage)
        
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.posepickUseCase
                .fetchPosePick(peopleCount: 4)
        })
        .disposed(by: disposeBag)
        
        self.posepickUseCase
            .poseImage
            .subscribe(onNext: {
                print($0)
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
    }

    override func tearDown() {
        super.tearDown()
        self.posepickUseCase = nil
        self.posepickRespository = nil
        self.scheduler = nil
        
        ImageDownloader.default.sessionConfiguration = .default
    }
}
