//
//  PoseFeedViewModelTests.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/4/24.
//

import XCTest
import RxSwift
import RxTest
@testable import posepicker
final class PoseFeedViewModelTests: XCTestCase {
    
    private var viewModel: PoseFeedViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: PoseFeedViewModel.Input!
    private var posefeedUseCase: PoseFeedUseCase!
    private var output: PoseFeedViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.posefeedUseCase = MockPoseFeedUseCase()
        self.viewModel = PoseFeedViewModel(
            coordinator: nil,
            posefeedUseCase: self.posefeedUseCase
        )
        self.disposeBag = DisposeBag()
    }

    override func tearDown() {
        
    }
}
