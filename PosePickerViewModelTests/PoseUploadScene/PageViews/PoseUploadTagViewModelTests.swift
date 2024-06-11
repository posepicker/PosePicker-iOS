//
//  PoseUploadTagViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadTagViewModelTests: XCTestCase {

    private var viewModel: PoseUploadTagViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var poseUploadCoordinator: PoseUploadCoordinator!
    private var input: PoseUploadTagViewModel.Input!
    private var output: PoseUploadTagViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.poseUploadCoordinator = MockPoseUploadCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.viewModel = PoseUploadTagViewModel(
            coordinator: self.poseUploadCoordinator
        )
    }
    
    func test_화면전환_테스트() {
        self.input = PoseUploadTagViewModel.Input(
            nextButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            expandButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, (CGPoint(x: 0, y: 0), nil))
            ]).asObservable(),
            inputCompleted: self.scheduler.createColdObservable([
                .next(0, true)
            ]).asObservable(),
            selectedTags: self.scheduler.createColdObservable([
                .next(0, ["재미", "유행"])
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.scheduler.start()
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.output = nil
        self.poseUploadCoordinator = nil
        self.viewModel = nil
    }

}
