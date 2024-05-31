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
        let buttonTapEvent = self.scheduler.createColdObservable([
            .next(0, ())
        ])
        let isAnimating = BehaviorRelay<Bool>(value: false)
        
        // 포즈톡 요청 후 로티 애니메이션 트리거 옵저버
        // 포즈 단어가 비어있는 경우 트리거 옵저버블에서 next 이벤트를 방출
        let animteTriggerObserver = self.scheduler.createObserver(Bool.self)
        
        // 포즈 단어 옵저버
        let poseWordObserver = self.scheduler.createObserver(String.self)
        
        self.input = PoseTalkViewModel.Input(
            poseTalkButtonTapped: .init(events: buttonTapEvent),
            isAnimating: isAnimating,
            tooltipButtonTapEvent: .empty(),
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
            .map { true }
            .subscribe(animteTriggerObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.posetalkUseCase.poseWord.onNext(nil)
        })
        .disposed(by: self.disposeBag)
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
