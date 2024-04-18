//
//  DetailUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/18/24.
//

import XCTest
import RxSwift
import RxTest

@testable import posepicker

final class DetailUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var poseDetailRespository: PoseDetailRepository!
    private var poseDetailUseCase: PoseDetailUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
    
        self.scheduler = .init(initialClock: 0)
        self.poseDetailRespository = MockPoseDetailRepository(
            isNil: false
        )
        self.poseDetailUseCase = DefaultPoseDetailUseCase(
            poseDetailRepository: self.poseDetailRespository,
            poseId: 10
        )
    }
    
    /// 포즈객체 & sourceURL & 기타 등등
    func test_포즈객체_잘_불러오는지() {
        let tagsTestObserver = self.scheduler.createObserver([String].self)
        let sourceTestObserver = self.scheduler.createObserver(String.self)
        let sourceURLObserver = self.scheduler.createObserver(String.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.poseDetailUseCase.getPoseInfo()
        })
        .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .tagItems
            .subscribe(tagsTestObserver)
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .source
            .subscribe(sourceTestObserver)
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .sourceUrl
            .subscribe(sourceURLObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        // tagAttributes 문자열에서 태그 배열로 파싱 되는지 체크
        XCTAssertEqual(tagsTestObserver.events, [
            .next(0, []),
            .next(0, ["친구","자연스러움","가족","재미"])
        ])
        
        XCTAssertEqual(sourceTestObserver.events, [
            .next(0, ""),
            .next(0, "@gangjuninggg")
        ])
        
        // HTTPS prefix 붙여서 URL 방출
        XCTAssertEqual(sourceURLObserver.events, [
            .next(0, ""),
            .next(0, "https://www.instagram.URL")
        ])
    }
    
    /// 정상 시나리오일때
    func test_북마크체크_정상_테스트() {
        let bookmarkTestObserver = self.scheduler.createObserver(Bool.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.poseDetailUseCase.bookmarkContent(poseId: 10, currentChecked: true)
            self?.poseDetailUseCase.bookmarkContent(poseId: 10, currentChecked: false)
            self?.poseDetailUseCase.bookmarkContent(poseId: 11, currentChecked: true)
        })
        .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .bookmarkTaskCompleted
            .subscribe(bookmarkTestObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(bookmarkTestObserver.events, [
            .next(0, true),
            .next(0, true),
            .next(0, false) // 북마크 매칭 안되는 예외처리
        ])
    }
    
    func test_북마크체크_비정상_테스트() {
        let bookmarkTestObserver = self.scheduler.createObserver(Bool.self)
        
        self.poseDetailRespository = MockPoseDetailRepository(
            isNil: true
        )
        self.poseDetailUseCase = DefaultPoseDetailUseCase(
            poseDetailRepository: self.poseDetailRespository,
            poseId: 10
        )
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.poseDetailUseCase.bookmarkContent(poseId: 10, currentChecked: true)
            self?.poseDetailUseCase.bookmarkContent(poseId: 10, currentChecked: false)
        })
        .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .bookmarkTaskCompleted
            .subscribe(bookmarkTestObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(bookmarkTestObserver.events, [
            .next(0, false),
            .next(0, false),
        ])
    }
    
    func test_포즈객체_nil값_포함될때_예외처리_테스트() {
        self.poseDetailRespository = MockPoseDetailRepository(
            isNil: true
        )
        self.poseDetailUseCase = DefaultPoseDetailUseCase(
            poseDetailRepository: self.poseDetailRespository,
            poseId: 10
        )
        
        let tagsTestObserver = self.scheduler.createObserver([String].self)
        let sourceTestObserver = self.scheduler.createObserver(String.self)
        let sourceURLObserver = self.scheduler.createObserver(String.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.poseDetailUseCase.getPoseInfo()
        })
        .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .tagItems
            .subscribe(tagsTestObserver)
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .source
            .subscribe(sourceTestObserver)
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .sourceUrl
            .subscribe(sourceURLObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        // tagAttributes 문자열에서 태그 배열로 파싱 되는지 체크
        XCTAssertEqual(tagsTestObserver.events, [
            .next(0, []),
            .next(0, [])
        ])
        
        XCTAssertEqual(sourceTestObserver.events, [
            .next(0, ""),
            .next(0, "")
        ])
        
        XCTAssertEqual(sourceURLObserver.events, [
            .next(0, ""),
            .next(0, "")
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.poseDetailRespository = nil
        self.disposeBag = DisposeBag()
        self.poseDetailUseCase = nil
        self.scheduler = nil
    }
}
