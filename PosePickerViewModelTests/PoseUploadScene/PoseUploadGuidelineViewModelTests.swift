//
//  PoseUploadGuidelineViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadGuidelineViewModelTests: XCTestCase {

    private var viewModel: MyPoseGuidelineViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var poseUploadCoordinator: PoseUploadCoordinator!
    private var input: MyPoseGuidelineViewModel.Input!
    private var output: MyPoseGuidelineViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.poseUploadCoordinator = MockPoseUploadCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.viewModel = MyPoseGuidelineViewModel(
            coordinator: self.poseUploadCoordinator
        )
    }
    
    func test_화면전환_테스트() {
        self.input = MyPoseGuidelineViewModel.Input(
            guidelineCheckButtonTapEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            imageLoadCompletedEvent: self.scheduler.createColdObservable([
                .next(0, nil)
            ]).asObservable(),
            imageLoadFailedEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.scheduler.start()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
