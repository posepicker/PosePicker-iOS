//
//  PosePickViewModelTests.swift
//  posepickerUITests
//
//  Created by 박경준 on 4/1/24.
//

import XCTest
import RxTest
import RxRelay
import RxSwift

@testable import posepicker

final class PosePickViewModelTests: XCTestCase {
    private var viewModel: PosePickViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var input: PosePickViewModel.Input!
    private var posepickUseCase: PosePickUseCase!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.posepickUseCase = MockPosePickUseCase()
        self.viewModel = PosePickViewModel(
            coordinator: nil,
            posepickUseCase: posepickUseCase
        )
        self.disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.disposeBag = nil
        self.posepickUseCase = nil
    }
    
    /// Input
    /// 1. 애니메이션 종료 여부
    /// 2. 포즈 요청 버튼 탭 + 인원 수 셀렉션 버튼 탭
    ///
    /// transform
    /// 1. 포즈 요청 버튼 탭
    /// 2. API 요청 후 데이터 불러오기
    /// 3. 데이터 다 불러와졌어도 잠시 대기, 로티 애니메이션 종료 여부 체크
    /// 4. isLoading으로 아웃풋 생성
    func test_버튼_탭_이후_이미지를_불러오기_로딩_상태값이랑_함께_검증 () {
        let peopleCountButtonTestableObservable = self.scheduler.createHotObservable([
            .next(5, 1)
        ])
        let posepickButtonTapTestableObservable = self.scheduler.createHotObservable([
            .next(10, ())
        ])
        let isAnimatingTestableObservable = self.scheduler.createHotObservable([
            .next(10, true),    // 로티 한사이클 돌리는데 1타임
            .next(12, false)
        ])
        
        let poseImageObserver = self.scheduler.createObserver(Data?.self)
        
        self.input = PosePickViewModel.Input(
            selectedPeopleCount: peopleCountButtonTestableObservable.asObservable(),
            posepickButtonEvent: posepickButtonTapTestableObservable.asObservable(),
            isAnimating: isAnimatingTestableObservable.asObservable()
        )
        
        self.viewModel.transform(input: input, disposeBag: self.disposeBag)
            .poseImage
            .map { $0.pngData()! }
            .subscribe(poseImageObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(poseImageObserver.events, [
            .next(12, ImageLiteral.imgInfo24.pngData()!)
        ])
    }

}
