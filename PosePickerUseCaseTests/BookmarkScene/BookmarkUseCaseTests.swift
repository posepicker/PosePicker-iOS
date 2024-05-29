//
//  BookmarkUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class BookmarkUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var bookmarkRepository: BookmarkRepository!
    private var bookmarkUseCase: BookmarkUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        self.bookmarkRepository = MockBookmarkRepository()
        self.bookmarkUseCase = DefaultBookmarkUseCase(
            bookmarkRepository: self.bookmarkRepository
        )
        self.scheduler = .init(initialClock: 0)
    }
    
    func test_pageNumber에_따라_데이터_잘_쌓이는지_그리고_마지막_페이지_조회중인지() {
        let countObserver = self.scheduler.createObserver(Int.self)
        let isLastObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, 0),
            .next(1, 1)
        ])
        .subscribe(onNext: { [weak self] pageNumber in
            self?.bookmarkUseCase.fetchFeedContents(pageNumber: pageNumber, pageSize: 8)
        })
        .disposed(by: disposeBag)
        
        self.bookmarkUseCase
            .bookmarkContents
            .map { $0.count }
            .subscribe(countObserver)
            .disposed(by: self.disposeBag)
        
        self.bookmarkUseCase
            .isLastPage
            .subscribe(isLastObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(countObserver.events, [
            .next(0, 0),
            .next(0, 0),
            .next(0, 8),
            .next(1, 10)
        ])
        
        XCTAssertEqual(isLastObserver.events, [
            .next(0, false),
            .next(0, false),
            .next(0, false),
            .next(1, true)
        ])
    }
    
    /// 세션 만료 혹은 로그아웃 이후 컨텐츠 다 지워지는지 테스트
    func test_컨텐츠_전체_삭제_테스트() {
        let contentsCountObserver = self.scheduler.createObserver(Int.self)
        let isLastObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, 0),
            .next(1, 1)
        ])
        .subscribe(onNext: { [weak self] pageNumber in
            self?.bookmarkUseCase.fetchFeedContents(pageNumber: pageNumber, pageSize: 8)
        })
        .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([
            .next(2, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.bookmarkUseCase.removeAllContents()
        })
        .disposed(by: self.disposeBag)
        
        self.bookmarkUseCase
            .bookmarkContents
            .map { $0.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.bookmarkUseCase
            .isLastPage
            .subscribe(isLastObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(isLastObserver.events, [
            .next(0, false),
            .next(0, false),
            .next(0, false),
            .next(1, true),
            .next(2, false)
        ])
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 0),
            .next(0, 0),
            .next(0, 8),
            .next(1, 10),
            .next(2, 0)
        ])
    }
    
    func test_북마크_체크가_잘_이루어지는지() {
        let bookmarkObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.bookmarkUseCase.bookmarkContent(poseId: 0, currentChecked: true)
            self?.bookmarkUseCase.bookmarkContent(poseId: 1, currentChecked: false)
        })
        .disposed(by: disposeBag)
        
        bookmarkUseCase.bookmarkTaskCompleted
            .subscribe(bookmarkObserver)
            .disposed(by: self.disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(bookmarkObserver.events, [
            .next(0, false),
            .next(0, true)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
        bookmarkRepository = nil
        bookmarkUseCase = nil
        scheduler = nil
    }

}
