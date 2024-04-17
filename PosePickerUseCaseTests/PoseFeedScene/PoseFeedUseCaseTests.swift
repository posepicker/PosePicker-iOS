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
        
        self.posefeedRespository = MockPoseFeedRepository()
        self.posefeedUseCase = DefaultPoseFeedUseCase(
            posefeedRepository: MockPoseFeedRepository()
        )
        self.scheduler = .init(initialClock: 0)
    }
    
    func test_컨텐츠_세팅_후_사이즈_잘_추출되는지() {
        let filteredContentSizesObserver = self.scheduler.createObserver(Int.self)
        let recommendedContentSizesObserver = self.scheduler.createObserver(Int.self)
        
        self.scheduler
            .createColdObservable([
                .next(0, ())
            ])
            .subscribe(onNext: { [weak self] in
                self?.posefeedUseCase
                    .fetchFeedContents(
                        peopleCount: "1인",
                        frameCount: "4컷",
                        filterTags: [],
                        pageNumber: 0
                    )
            })
            .disposed(by: self.disposeBag)
        
        self.scheduler
            .createColdObservable([
                .next(1, ())
            ])
            .subscribe(onNext: { [weak self] in
                self?.posefeedUseCase
                    .fetchFeedContents(
                        peopleCount: "1인",
                        frameCount: "4컷",
                        filterTags: [],
                        pageNumber: 1
                    )
            })
            .disposed(by: disposeBag)
        
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
        
        // BehaviorRelay로 인해 초기값 빈 배열 한번 방출
        // pageNumber 0일때 사이즈 전체 초기화를 위해 빈 배열 방출
        XCTAssertEqual(filteredContentSizesObserver.events, [
            .next(0, 0),
            .next(0, 0),
            .next(0, 1),
            .next(1, 2)
        ])
        
        /// 이미지가 nil일때 (다운로드 실패한 경우)
        /// 사이즈 옵저버블에서 아무것도 방출하지 않게 된다
        XCTAssertEqual(recommendedContentSizesObserver.events, [
            .next(0, 0),
            .next(0, 0),
            .next(0, 1),
            .next(1, 2)
        ])
    }
    
    func test_라스트페이지_여부_체크() {
        let isLastPageTestObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: {
            self.posefeedUseCase
                .fetchFeedContents(peopleCount: "", frameCount: "", filterTags: [], pageNumber: 0)
        })
        .disposed(by: disposeBag)
        
        self.posefeedUseCase
            .isLastPage
            .subscribe(isLastPageTestObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        // 하드코딩 옵저버블 - 필터 데이터는 마지막 페이지 아닌데, 추천 데이터는 마지막 페이지일때 최종적으로 false 리턴
        XCTAssertEqual(isLastPageTestObserver.events, [
            .next(0, false),
            .next(0, true)
        ])
    }
    
    func test_북마크_동작_테스트() {
        let bookmarkTaskTestObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.posefeedUseCase
                .bookmarkContent(poseId: 1, currentChecked: true)
            
            self?.posefeedUseCase
                .bookmarkContent(poseId: 0, currentChecked: true)
        })
        .disposed(by: self.disposeBag)
        
        self.posefeedUseCase
            .bookmarkTaskCompleted
            .subscribe(bookmarkTaskTestObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(bookmarkTaskTestObserver.events, [
            .next(0, true),
            .next(0, false)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.posefeedRespository = nil
        self.posefeedUseCase = nil
        self.scheduler = nil
    }
}
