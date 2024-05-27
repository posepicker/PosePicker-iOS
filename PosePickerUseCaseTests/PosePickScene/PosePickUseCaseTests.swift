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

    private var disposeBag = DisposeBag()
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
    }
    
    // MARK: - 비동기처리 과정
    /// 1. .next(0, ()) 이벤트 방출
    /// 2. fetchPosePick 호출
    /// 3. 첫번째 이미지 캐싱 진행
    /// 4. 디스패치 큐로 이미지 다운로드 태스크 이동
    /// 5. .next(5, ()) 진행
    /// 6. 이미지 다운로드중에 fetchPosePick 호출
    /// 7. 캐시 확인 -> cache miss 발생
    func test_디스크_캐싱_처리가_잘_되는지 (){
        let expectation = XCTestExpectation(description: "포즈픽 유스케이스 데이터 잘 불러오는지")
        
        expectation.expectedFulfillmentCount = 2
        MockURLProtocol.responseWithStatusCode(code: 200)
        MockURLProtocol.responseWithDTO(type: .cacheImage)
        
        self.scheduler.createColdObservable([
            .next(0, ()),
            .next(3, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.posepickUseCase
                .fetchPosePick(peopleCount: 4)
        })
        .disposed(by: disposeBag)
        
        self.posepickUseCase
            .poseImage
            .subscribe(onNext: { [weak self] image in
                print("posepick image: ",image)
                ImageCache.default.retrieveImage(forKey: "https://posepicker-image.s3.ap-northeast-2.amazonaws.com/6fc77625e557babd80e8e389baf798c12a8d210d9c148de6595962923d81481b.jpg") { result in
                    expectation.fulfill()
                    switch result {
                    case .success(let value):
                        print("cache hit!: \(value.cacheType)")
                    case .failure:
                        print("cache miss..")
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 10)
    }

    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.posepickUseCase = nil
        self.posepickRespository = nil
        self.scheduler = nil
        
        ImageDownloader.default.sessionConfiguration = .default
    }
}
