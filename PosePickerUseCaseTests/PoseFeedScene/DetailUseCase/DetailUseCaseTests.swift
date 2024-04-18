//
//  DetailUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/18/24.
//

import XCTest
import RxSwift
import RxTest

@testable import posepicker

final class DetailUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var poseDetailRespository: PoseDetailRepository!
    private var poseDetailUseCase: PoseDetailUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        self.poseDetailRespository = MockPoseDetailRepository()
        self.poseDetailUseCase = DefaultPoseDetailUseCase(
            poseDetailRepository: self.poseDetailRespository,
            poseId: 10
        )
        self.scheduler = .init(initialClock: 0)
    }
    
    override func tearDown() {
        
    }
}
