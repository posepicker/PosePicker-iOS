//
//  PoseUploadUseCaseTests.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import XCTest
import RxTest
import RxSwift

@testable import posepicker

final class PoseUploadUseCaseTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var poseUploadRepository: PoseUploadRepository!
    private var poseUploadUseCase: PoseUploadUseCase!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.poseUploadRepository = MockPoseUploadRepository()
        self.poseUploadUseCase = DefaultPoseUploadUseCase(
            poseUploadRepository: self.poseUploadRepository
        )
        self.scheduler = .init(initialClock: 0)
    }
    
    func test_포즈업로드_테스트() {
        let peopleCountObserver = self.scheduler.createObserver(Int.self)
        let frameCountObserver = self.scheduler.createObserver(Int.self)
        
        self.scheduler.createColdObservable([
            .next(0, ())
        ])
        .subscribe(onNext: { [weak self] in
            self?.poseUploadUseCase.savePose(
                image: ImageLiteral.imgAppleLogo,
                frameCount: "1컷",
                peopleCount: "2인",
                source: "@gangjuninggg",
                sourceUrl: "https://www.instagram.com/gangggjuninggg?igsh=d2h4YXY2NmF3YWZq&utm_source=qr",
                tag: "연예인,유명인"
            )
        })
        .disposed(by: disposeBag)
        
        self.poseUploadUseCase
            .uploadCompletedEvent
            .map { $0.poseInfo.frameCount }
            .compactMap { $0 }
            .subscribe(frameCountObserver)
            .disposed(by: self.disposeBag)
        
        self.poseUploadUseCase
            .uploadCompletedEvent
            .map { $0.poseInfo.peopleCount }
            .compactMap { $0 }
            .subscribe(peopleCountObserver)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(peopleCountObserver.events, [
            .next(0, 2)
        ])
        
        XCTAssertEqual(frameCountObserver.events, [
            .next(0, 1)
        ])
    }
    
    override func tearDown() {
        super.tearDown()
        self.disposeBag = DisposeBag()
        self.poseUploadRepository = nil
        self.poseUploadUseCase = nil
        self.scheduler = nil
    }
    
}
