//
//  MyPoseUploadedViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/3/24.
//

import XCTest
import RxTest
import RxSwift
@testable import posepicker

final class MyPoseUploadedViewModelTests: XCTestCase {
    
    private var viewModel: MyPoseUploadedViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: MyPoseUploadedViewModel.Input!
    private var myPoseUsecase: MyPoseUseCase!
    private var output: MyPoseUploadedViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.myPoseUsecase = MockMyPoseUseCase()
        self.viewModel = MyPoseUploadedViewModel(
            coordinator: nil,
            myPoseUseCase: self.myPoseUsecase
        )
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        self.input = nil
        self.myPoseUsecase = nil
        self.output = nil
    }
}
