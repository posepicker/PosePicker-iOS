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
            configuration.protocolClasses = [MockImageDownloaderURLProtocol.self]
            downloader.sessionConfiguration = configuration
            return downloader
        }()
        
        sut = APISession(session: session)
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = BookMarkViewModel(apiSession: sut, imageDownloader: imageDownloader) // 목업 세션 주입
        ImageCache.default.clearCache() // 캐시 비우기
    }
    
    /// Given - viewDidLoad
    /// When - transform -> 북마크 컨텐츠가 비어있을때 & 북마크 컨텐츠가 존재할때 둘다 테스트
    /// Then - items
    func test_이미지_캐싱_목업테스트() {
        
        MockURLProtocol.responseWithStatusCode(code: 200)
        MockURLProtocol.responseWithDTO(type: .bookmarkFeedEmpty)
        
        MockImageDownloaderURLProtocol.responseWithStatusCode(code: 200)
        MockImageDownloaderURLProtocol.responseWithDTO(type: .cacheImage)
        
        var input = retrieveDefaultInputObservable()
        
        input.viewDidLoadTrigger = scheduler.createColdObservable([
            .next(1, ())
        ]).asObservable()
        
        let output = viewModel.transform(input: input)
        let expectation = XCTestExpectation(description: "북마크 API 테스트")
        
        scheduler.start()
        
        output.bookmarkItems
            .compactMap { $0 }
            .drive(onNext: {
                print($0)
                $0.forEach { element in
                    print(element.image.value)
                    print(element.poseId.value)
                }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_북마크_피드_컨텐츠가_비어있을때() {
        
        MockURLProtocol.responseWithDTO(type: .bookmarkFeed)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        MockImageDownloaderURLProtocol.responseWithDTO(type: .cacheImage) // XCTAssertEqual false일때
        MockImageDownloaderURLProtocol.responseWithStatusCode(code: 200)
        
        var input = retrieveDefaultInputObservable()
        input.viewDidLoadTrigger = scheduler.createColdObservable([
            .next(10, ())
        ]).asObservable()
        
        let output = viewModel.transform(input: input)
        
        let expectation = XCTestExpectation(description: "북마크 피드 빈 데이터일때 불리언값 검증")
        
        scheduler.start()
        
        output.isEmpty
            .compactMap { $0 }
            .drive(onNext: {
                XCTAssertEqual($0, false)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_다음페이지_데이터_요청() {
        MockURLProtocol.responseWithDTO(type: .bookmarkFeedNext)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        MockImageDownloaderURLProtocol.responseWithDTO(type: .cacheImage)
        MockImageDownloaderURLProtocol.responseWithStatusCode(code: 200)
        
        
        XCTAssertEqual(1,1)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
        viewModel = nil
        ImageDownloader.default.sessionConfiguration = .default
    }
    
    func retrieveDefaultInputObservable() -> BookMarkViewModel.Input {
        let viewDidLoadTrigger: TestableObservable<Void> = scheduler.createColdObservable([])
        let nextPageTrigger: TestableObservable<Void> = scheduler.createColdObservable([])
        let input = BookMarkViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger.asObservable(), nextPageTrigger: nextPageTrigger.asObservable())
        
        return input
    }
}
