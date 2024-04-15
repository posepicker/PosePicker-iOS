//
//  PoseFeedUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/4/24.
//

import XCTest
import RxSwift
import RxTest
import Kingfisher

@testable import posepicker

final class PoseFeedUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var posefeedRespository: PoseFeedRepository!
    private var posefeedUseCase: PoseFeedUseCase!
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
        
        self.posefeedRespository = MockPoseFeedRepository()
        self.posefeedUseCase = DefaultPoseFeedUseCase(
            posefeedRepository: MockPoseFeedRepository()
        )
        self.scheduler = .init(initialClock: 0)
        
        ImageCache.default.clearCache()
    }
    
    func test_컨텐츠_세팅_후_사이즈_잘_추출되는지() {
        let filteredContentSizesObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentSizesObserver = self.scheduler.createObserver(Int.self)
        
        self.posefeedUseCase
            .fetchFeedContents(
                peopleCount: "1인",
                frameCount: "4컷",
                filterTags: [],
                pageNumber: 0
            )
        
        self.posefeedUseCase
            .filterSectionContentSizes
            .map { $0.count }
            .subscribe(filteredContentSizesObserver)
            .disposed(by: self.disposeBag)
        
        self.posefeedUseCase
            .recommendSectionContentSizes
            .map { $0.count }
            .subscribe(recommendedContentSizesObserver)
            .disposed(by: self.disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(filteredContentSizesObserver.events, [
            .next(0, 1)
        ])
        
        XCTAssertEqual(recommendedContentSizesObserver.events, [
            .next(0, 1)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.posefeedRespository = nil
        self.posefeedUseCase = nil
        self.scheduler = nil
        ImageDownloader.default.sessionConfiguration = .default
    }
}
