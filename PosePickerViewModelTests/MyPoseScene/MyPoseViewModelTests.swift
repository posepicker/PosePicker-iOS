//
//  MyPoseViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/8/24.
//

import XCTest
import RxSwift
import RxTest
@testable import posepicker

final class MyPoseViewModelTests: XCTestCase {
    
    private var viewModel: MyPoseViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: MyPoseViewModel.Input!
    private var myPoseUsecase: MyPoseUseCase!
    private var output: MyPoseViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.myPoseUsecase = MockMyPoseUseCase()
        self.viewModel = MyPoseViewModel(
            coordinator: nil,
            myPoseUseCase: MockMyPoseUseCase()
        )
        
        self.disposeBag = DisposeBag()
    }
    
    func test_뷰_로드_이후_카운트값_불러오는지() {
        let viewDidLoadObservable = self.scheduler.createHotObservable([
            .next(1, ())
        ])
        
        self.input = MyPoseViewModel.Input(
            viewDidLoadEvent: viewDidLoadObservable.asObservable()
        )
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        let uploadedCountObserver = self.scheduler.createObserver(String.self)
        let savedCountObserver = self.scheduler.createObserver(String.self)
        
        output.savedCount
            .subscribe(savedCountObserver)
            .disposed(by: self.disposeBag)
        
        output.uploadedCount
            .subscribe(uploadedCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(uploadedCountObserver.events, [
            .next(0, "등록 0"),
            .next(1, "등록 10")
        ])
        
        XCTAssertEqual(savedCountObserver.events, [
            .next(0, "저장 0"),
            .next(1, "저장 10")
        ])
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.myPoseUsecase = nil
        self.output = nil
    }

}
