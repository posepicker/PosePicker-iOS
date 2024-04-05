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
    
    override func tearDown() {
        
    }
}
