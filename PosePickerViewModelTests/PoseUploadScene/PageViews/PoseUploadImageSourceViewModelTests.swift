//
//  PoseUploadImageSourceViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadImageSourceViewModelTests: XCTestCase {
    
    private var viewModel: PoseUploadImageSourceViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var poseuploadUsecase: PoseUploadUseCase!
    private var poseUploadCoordinator: PoseUploadCoordinator!
    private var input: PoseUploadImageSourceViewModel.Input!
    private var output: PoseUploadImageSourceViewModel.Output!

    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.poseUploadCoordinator = MockPoseUploadCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.poseuploadUsecase = MockPoseUploadUseCase()
        self.viewModel = PoseUploadImageSourceViewModel(
            coordinator: self.poseUploadCoordinator,
            poseUploadUseCase: self.poseuploadUsecase
        )
    }
    
    func test_포즈업로드_테스트() {
        let loadingObservable = self.scheduler.createObserver(Bool.self)
        let poseObservable = self.scheduler.createObserver(Pose.self)
        
        self.input = PoseUploadImageSourceViewModel.Input(
            sourceURL: self.scheduler.createColdObservable([
                .next(0, "https://인스타URL.com")
            ]).asObservable(),
            submitButtonTapEvent: self.scheduler.createColdObservable([
                .next(1, ()),
                .error(2, APIError.http(status: 500))
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .isLoading
            .subscribe(loadingObservable)
            .disposed(by: self.disposeBag)
        
        self.poseuploadUsecase
            .uploadCompletedEvent
            .subscribe(poseObservable)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(loadingObservable.events, [
            .next(0, false),
            .next(1, true),
            .next(1, false),
            .next(2, false)
        ])
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
