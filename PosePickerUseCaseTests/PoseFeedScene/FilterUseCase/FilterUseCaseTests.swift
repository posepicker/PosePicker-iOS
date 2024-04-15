//
//  FilterUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/5/24.
//

import XCTest
import RxSwift
import RxTest

@testable import posepicker

final class FilterUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var poseFeedUseCase: PoseFeedFilterUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler.init(initialClock: 0)
        self.poseFeedUseCase = DefaultPoseFeedFilterUseCase()
    }
    
    /// 잘못된 태그 스트링 입력시 예외처리까지 검증
    func test_태그_셀렉팅_적용되는지() {
        let tagTapObservable = self.scheduler.createHotObservable([
            .next(0, "잘못된 태그"),
            .next(1, "친구"),
            .next(2, "친구")
        ])
        
        tagTapObservable
            .subscribe(onNext: { [weak self] in
                self?.poseFeedUseCase.selectItem(title: $0)
            })
            .disposed(by: disposeBag)
        
        let tagSelectedObserver = self.scheduler.createObserver(Bool.self)
        
        poseFeedUseCase.selectItem(title: "잘못된 태그")
        
        poseFeedUseCase.tagItems.value[0].isSelected
            .subscribe(tagSelectedObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(tagSelectedObserver.events, [
            .next(0, false),
            .next(1, true),
            .next(2, false)
        ])
    }
    
    func test_태그리셋_후_모든_태그_초기화되는지() {
        let tagTapObservable = self.scheduler.createHotObservable([
            .next(0, "친구"),
            .next(0, "커플")
        ])
        
        let peopleCountTapObservabable = self.scheduler.createHotObservable([
            .next(0, 1)
        ])
        
        let frameCountTapObservable = self.scheduler.createHotObservable([
            .next(0, 1)
        ])
        
        let resetButtonTapObservable = self.scheduler.createHotObservable([
            .next(1, ())
        ])
        
        let friendTagSelectedObserver = self.scheduler.createObserver(Bool.self)
        let coupleTagSelectedObserver = self.scheduler.createObserver(Bool.self)
        let peopleCountSelectedObserver = self.scheduler.createObserver(Int.self)
        let frameCountSelectedObserver = self.scheduler.createObserver(Int.self)
        
        tagTapObservable
            .subscribe(onNext: { [weak self] in
                self?.poseFeedUseCase.selectItem(title: $0)
            })
            .disposed(by: disposeBag)
        
        resetButtonTapObservable
            .subscribe(onNext: { [weak self] in
                self?.poseFeedUseCase.resetAllTags()
            })
            .disposed(by: disposeBag)
        
        peopleCountTapObservabable
            .subscribe(onNext: { [weak self] in
                self?.poseFeedUseCase.selectPeopleCount(value: $0)
            })
            .disposed(by: disposeBag)
        
        frameCountTapObservable
            .subscribe(onNext: { [weak self] in
                self?.poseFeedUseCase.selectFrameCount(value: $0)
            })
            .disposed(by: disposeBag)
        
        poseFeedUseCase.tagItems.value[0].isSelected
            .subscribe(friendTagSelectedObserver)
            .disposed(by: disposeBag)
        
        poseFeedUseCase.tagItems.value[1].isSelected
            .subscribe(coupleTagSelectedObserver)
            .disposed(by: disposeBag)
        
        poseFeedUseCase.peopleCount
            .subscribe(peopleCountSelectedObserver)
            .disposed(by: disposeBag)
        
        poseFeedUseCase.frameCount
            .subscribe(frameCountSelectedObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(friendTagSelectedObserver.events, [
            .next(0, false),
            .next(0, true),
            .next(1, false)
        ])
        
        XCTAssertEqual(coupleTagSelectedObserver.events, [
            .next(0, false),
            .next(0, true),
            .next(1, false)
        ])
        
        XCTAssertEqual(peopleCountSelectedObserver.events, [
            .next(0, 0),
            .next(0, 1),
            .next(1, 0)
        ])
        
        XCTAssertEqual(frameCountSelectedObserver.events, [
            .next(0, 0),
            .next(0, 1),
            .next(1, 0)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.poseFeedUseCase = nil
        self.scheduler = nil
    }
}
