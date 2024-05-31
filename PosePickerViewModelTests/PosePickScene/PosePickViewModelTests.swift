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
    private var output: PosePickViewModel.Output!
    
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
            .next(5, 1),
            .next(13, 2)
        ])
        let posepickButtonTapTestableObservable = self.scheduler.createHotObservable([
            .next(10, ())
        ])
        let isAnimatingTestableObservable = self.scheduler.createHotObservable([
            .next(10, true),    // 로티 한사이클 돌리는데 1타임
            .next(12, false)
        ])
        
        let poseImageObserver = self.scheduler.createObserver(Data?.self)
        let animateTriggerObserver = self.scheduler.createObserver(Bool.self)
        
        self.input = PosePickViewModel.Input(
            selectedPeopleCount: peopleCountButtonTestableObservable.asObservable(),
            posepickButtonEvent: posepickButtonTapTestableObservable.asObservable(),
            isAnimating: isAnimatingTestableObservable.asObservable(),
            imageViewTapEvent: .just(nil)
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        self.output
            .poseImage
            .compactMap { $0 }
            .map { $0.pngData()! }
            .subscribe(poseImageObserver)
            .disposed(by: self.disposeBag)
        
        self.output
            .animate
            .map { true }
            .subscribe(animateTriggerObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        /// 실패 케이스 1. flatMapLatest로 셀렉션과 요청 버튼이 결합된 이후
        /// 셀렉션 버튼만 탭해도 요청이 진행되는 문제
        XCTAssertEqual(poseImageObserver.events, [
            .next(12, ImageLiteral.imgInfo24.pngData()!)
        ])
        
        /// 실패 케이스 2. flatMapLatest로 셀렉션과 요청 버튼이 결합된 이후
        /// 셀렉션 버튼만 탭해도 애니메이션이 트리거되는 문제
        XCTAssertEqual(animateTriggerObserver.events, [
            .next(10, true),
        ])
    }
    
    func test_포즈픽_이미지_로딩이_아직_안끝났을때_애니메이션_한번_더_트리거() {
        let peopleCountButtonTestableObservable = self.scheduler.createHotObservable([
            .next(5, 1)
        ])
        let posepickButtonTapTestableObservable = self.scheduler.createHotObservable([
            .next(10, ())
        ])
        let isAnimatingTestableObservable = self.scheduler.createHotObservable([
            .next(10, true),    // 로티 한사이클 돌리는데 1타임
            .next(11, false)
        ])
        
        let animateTriggerObserver = self.scheduler.createObserver(Bool.self)
        
        self.input = PosePickViewModel.Input(
            selectedPeopleCount: peopleCountButtonTestableObservable.asObservable(),
            posepickButtonEvent: posepickButtonTapTestableObservable.asObservable(),
            isAnimating: isAnimatingTestableObservable.asObservable(),
            imageViewTapEvent: Observable<UIImage?>.empty()
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        self.output
            .animate
            .map { true }
            .subscribe(animateTriggerObserver)
            .disposed(by: self.disposeBag)
        
        /// 12타임에 애니메이션 1사이클 종료가 되었음에도 이미지가 nil인 상황
        /// 로드가 안되었기때문에 애니메이션 다시 트리거 해야됨
        /// 요청 진행하면 다시 이미지 nil로 세팅
        // MARK: - 스케줄러 위치는 테스트 직전에!
        self.scheduler.start()
        self.posepickUseCase.poseImage.onNext(nil)
        
        XCTAssertEqual(animateTriggerObserver.events, [
            .next(10, true),
            .next(11, true)
        ])
    }
    
    func test_이미지_불러온_뒤_로티_숨겨지는지() {
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
        
        self.input = PosePickViewModel.Input(
            selectedPeopleCount: peopleCountButtonTestableObservable.asObservable(),
            posepickButtonEvent: posepickButtonTapTestableObservable.asObservable(),
            isAnimating: isAnimatingTestableObservable.asObservable(),
            imageViewTapEvent: Observable<UIImage?>.empty()
        )
        
        self.output = self.viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        let lottieHiddenObserver = self.scheduler.createObserver(Bool.self)
        
        self.output.lottieImageHidden
            .bind(to: lottieHiddenObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(lottieHiddenObserver.events, [
            .next(12, true)
        ])
    }

}
