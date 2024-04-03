//
//  CommonSceneUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/2/24.
//

import XCTest
import RxTest
import RxSwift
@testable import posepicker

final class CommonSceneUseCaseTests: XCTestCase {

    private let disposeBag = DisposeBag()
    private var userRepository: UserRepository!
    private var commonUseCase: CommonUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.userRepository = MockUserRepository()
        self.commonUseCase = DefaultCommonUseCase(
            userRepository: self.userRepository
        )
        self.scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        self.userRepository = nil
        self.commonUseCase = nil
        self.scheduler = nil
    }

}
