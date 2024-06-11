//
//  PoseUploadHeadcountViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadHeadcountViewModelTests: XCTestCase {

    private var viewModel: PoseUploadHeadcountViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var poseUploadCoordinator: PoseUploadCoordinator!
    private var input: PoseUploadHeadcountViewModel.Input!
    private var output: PoseUploadHeadcountViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.poseUploadCoordinator = MockPoseUploadCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.viewModel = PoseUploadHeadcountViewModel(
            coordinator: self.poseUploadCoordinator
        )
    }
    
    func test_화면전환_테스트() {
        self.input = PoseUploadHeadcountViewModel.Input(
            nextButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            expandButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, (CGPoint(x: 0, y: 0), nil))
            ]).asObservable(),
            selectedHeadCount: self.scheduler.createColdObservable([
                .next(0, "")
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
