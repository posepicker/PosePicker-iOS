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
import Kingfisher
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
        
        let imageDownloader: ImageDownloader = {
            let downloader = ImageDownloader.default
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockImageDownloaderIURLProtocol.self]
            downloader.sessionConfiguration = configuration
//            downloader.sessionConfiguration.protocolClasses = [MockImageDownloaderIURLProtocol.self]
            return downloader
        }()
        
        sut = APISession(session: session)
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = BookMarkViewModel(apiSession: sut, imageDownloader: imageDownloader) // 목업 세션 주입
        ImageCache.default.clearCache() // 캐시 비우기
    }
    
    /// Given - viewDidLoad
    /// When - transform
    /// Then - items
    func test_데이터가_없을때_empty뷰를_띄워주는지() {
        
        MockURLProtocol.responseWithStatusCode(code: 200)
        MockURLProtocol.responseWithDTO(type: .bookmarkFeed)
        
        MockImageDownloaderIURLProtocol.responseWithStatusCode(code: 200)
        MockImageDownloaderIURLProtocol.responseWithDTO(type: .cacheImage)
        
        var input = retrieveDefaultInputObservable()
        
        input.viewDidLoadTrigger = scheduler.createColdObservable([
            .next(1, ())
        ]).asObservable()
        
        let output = viewModel.transform(input: input)
        let expectation = XCTestExpectation(description: "북마크 API 테스트")
        
        scheduler.start()
        
        // 네트워크에 의존중..
        output.bookmarkItems
            .compactMap { $0 }
            .drive(onNext: {
                // 캐시처리가 오래걸리나?
                $0.forEach { element in
                    print(element.image.value)
                    print(element.poseId.value)
                }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
        viewModel = nil
    }
    
    func retrieveDefaultInputObservable() -> BookMarkViewModel.Input {
        let viewDidLoadTrigger: TestableObservable<Void> = scheduler.createColdObservable([])
        let input = BookMarkViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger.asObservable())
        
        return input
    }
}
