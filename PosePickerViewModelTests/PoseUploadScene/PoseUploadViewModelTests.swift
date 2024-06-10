//
//  PoseUploadViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadViewModelTests: XCTestCase {
    private var viewModel: PoseUploadViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var poseUploadCoordinator: PoseUploadCoordinator!
    private var input: PoseUploadViewModel.Input!
    private var output: PoseUploadViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.poseUploadCoordinator = MockPoseUploadCoordinator(
            UINavigationController(
                rootViewController: UIViewController()
            )
        )
        self.viewModel = PoseUploadViewModel(
            coordinator: self.poseUploadCoordinator
        )
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
    }
    
    func test_페이지_전환_테스트() {
        let pageNumberObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseUploadViewModel.Input(
            pageviewTransitionDelegateEvent: self.scheduler.createColdObservable([
                .next(0, ())
            ]).asObservable(),
            currentPage: .empty()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .pageTransitionEvent
            .subscribe(pageNumberObserver)
            .disposed(by: self.disposeBag)
        
        _ = viewModel.viewControllerBefore()
        _ = viewModel.viewControllerAfter()
        
        self.scheduler.start()
        
        XCTAssertEqual(pageNumberObserver.events, [
            .next(0, 0)
        ])
    }
    
    func test_currentPage_세팅_테스트() {
        let segmentIndexObserver = self.scheduler.createObserver(Int.self)
        
        self.input = PoseUploadViewModel.Input(
            pageviewTransitionDelegateEvent: .empty(),
            currentPage: self.scheduler.createColdObservable([
                .next(1, 1)
            ]).asObservable()
        )
        
        self.output = self.viewModel.transform(input: self.input, disposeBag: self.disposeBag)
        
        self.output
            .selectedSegmentIndex
            .subscribe(segmentIndexObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(segmentIndexObserver.events, [
            .next(0, 0),
            .next(1, 1)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.poseUploadCoordinator = nil
        self.input = nil
        self.output = nil
    }
}
