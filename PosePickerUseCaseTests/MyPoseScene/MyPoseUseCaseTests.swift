//
//  MyPoseUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class MyPoseUseCaseTests: XCTestCase {

    private var disposeBag = DisposeBag()
    private var myposeRespository: MyPoseRepository!
    private var myposeUseCase: MyPoseUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        self.myposeRespository = MockMyPoseRepository()
        self.myposeUseCase = DefaultMyPoseUseCase(
            myPoseRepository: self.myposeRespository
        )
        self.scheduler = TestScheduler.init(initialClock: 0)
    }
    
    func test_북마크_체크가_잘_이루어지는지() {
        let bookmarkObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createHotObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.myposeUseCase.bookmarkContent(poseId: 0, currentChecked: true)
            self?.myposeUseCase.bookmarkContent(poseId: 1, currentChecked: false)
        })
        .disposed(by: disposeBag)
        
        myposeUseCase.bookmarkTaskCompleted
            .subscribe(bookmarkObserver)
            .disposed(by: self.disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(bookmarkObserver.events, [
            .next(0, false),
            .next(0, true)
        ])
    }
    
    func test_pageNumber에_따라_데이터_잘_쌓이는지_그리고_마지막_페이지_조회중인지() {
        let countObserver = self.scheduler.createObserver(Int.self)
        let isLastObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, 0),
            .next(1, 1)
        ])
        .subscribe(onNext: { [weak self] pageNumber in
            self?.myposeUseCase.fetchFeedContents(pageNumber: pageNumber, pageSize: 8)
        })
        .disposed(by: disposeBag)
        
        self.myposeUseCase
            .uploadedContents
            .map { $0.count }
            .subscribe(countObserver)
            .disposed(by: self.disposeBag)
        
        self.myposeUseCase
            .isLastPage
            .subscribe(isLastObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(countObserver.events, [
            .next(0, 0),
            .next(0, 8),
            .next(1, 10)
        ])
        
        XCTAssertEqual(isLastObserver.events, [
            .next(0, false),
            .next(0, false),
            .next(1, true)
        ])
    }
    
    /// 북마크 체크 했을때 포즈 카운트값 새로 업데이트 되어야함
    /// 업로드 컨텐츠에서 북마크 버튼 탭 이후 북마크 카운트 값 + 1 되는지 테스트
    func test_포즈_카운트값_요청_테스트() {
        let uploadedPoseCountObserver = self.scheduler.createObserver(String.self)
        let savePoseCountObserver = self.scheduler.createObserver(String.self)
        
        self.scheduler.createColdObservable([
            .next(0, ()),
            .next(2, ()),
            .next(4, ()),
            .next(6, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.myposeUseCase.fetchPoseCount()
        })
        .disposed(by: self.disposeBag)
        
        self.scheduler.createColdObservable([
            .next(1, (1, false)),
            .next(3, (11, false)),
            .next(5, (3, true))
        ])
        .subscribe(onNext: { [weak self] (poseId, currentChecked) in
            self?.myposeUseCase.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
        })
        .disposed(by: self.disposeBag)
        
        self.myposeUseCase
            .savedPoseCount
            .subscribe(savePoseCountObserver)
            .disposed(by: disposeBag)
        
        self.myposeUseCase
            .uploadedPoseCount
            .subscribe(uploadedPoseCountObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(savePoseCountObserver.events, [
            .next(0, "저장 10"),
            .next(2, "저장 11"),
            .next(4, "저장 12"),
            .next(6, "저장 11")
        ])
        
        XCTAssertEqual(uploadedPoseCountObserver.events, [
            .next(0, "등록 10"),
            .next(2, "등록 10"),
            .next(4, "등록 10"),
            .next(6, "등록 10"),
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
            self?.myposeUseCase.fetchFeedContents(pageNumber: pageNumber, pageSize: 8)
        })
        .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([
            .next(2, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.myposeUseCase.removeAllContents()
        })
        .disposed(by: self.disposeBag)
        
        self.myposeUseCase
            .uploadedContents
            .map { $0.count }
            .subscribe(contentsCountObserver)
            .disposed(by: self.disposeBag)
        
        self.myposeUseCase
            .isLastPage
            .subscribe(isLastObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(isLastObserver.events, [
            .next(0, false),
            .next(0, false),
            .next(1, true),
            .next(2, false)
        ])
        
        XCTAssertEqual(contentsCountObserver.events, [
            .next(0, 0),
            .next(0, 8),
            .next(1, 10),
            .next(2, 0)
        ])
    }

    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.myposeRespository = nil
        self.myposeUseCase = nil
        self.scheduler = nil
    }
}
