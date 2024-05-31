//
//  PoseTalkViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/31/24.
//

import XCTest
import RxTest

import RxSwift
import RxCocoa

@testable import posepicker

final class PoseTalkViewModelTests: XCTestCase {
    
    private var posetalkUseCase: PoseTalkUseCase!
    private var viewModel: PoseTalkViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: PoseTalkViewModel.Input!
    private var output: PoseTalkViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.posetalkUseCase = MockPoseTalkUseCase()
        self.viewModel = PoseTalkViewModel(
            coordinator: nil,
            posetalkUseCase: self.posetalkUseCase
        )
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
    }
    
    /// 1. 버튼 탭
    /// 2. 
    func test_애니메이션_테스트() {
        // MARK: - 테스트 옵저버블
        let buttonTapEvent = self.scheduler.createColdObservable([
            .next(0, ())
        ])
        
        // MARK: - 인풋 옵저버블
        let isAnimating = BehaviorRelay<Bool>(value: false)
        
        // MARK: - 옵저버
        let posewordObserver = self.scheduler.createObserver(String.self)
        
        // MARK: - Expectation
        let expectation = XCTestExpectation(description: "포즈 단어 로딩중일때 애니메이션 5번 트리거 되는지")
        expectation.expectedFulfillmentCount = 5
        
        self.input = PoseTalkViewModel.Input(
            poseTalkButtonTapped: .init(events: buttonTapEvent),
            isAnimating: isAnimating,
            tooltipButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            viewDidLoadEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            viewDidDisappearEvent: self.scheduler.createColdObservable([
                .next(100, ())
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .animate
            .subscribe(onNext: {
                isAnimating.accept(true)
                expectation.fulfill()
                isAnimating.accept(false)
            })
            .disposed(by: self.disposeBag)
        
        self.output
            .poseWord
            .subscribe(posewordObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.createColdObservable([
            .next(2, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.posetalkUseCase.fetchPoseTalk()
            self?.posetalkUseCase.isLoading.accept(false)
        })
        .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(posewordObserver.events, [
            .next(2, "고개들어 하늘 보라")  // 1. 최종 값 방출
        ])
    }

    override func tearDown() {
        super.tearDown()
        self.posetalkUseCase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.output = nil
    }
}
