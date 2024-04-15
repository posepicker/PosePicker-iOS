//
//  MockPosePickUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/1/24.
//

import UIKit
import RxSwift
import XCTest

@testable import posepicker

// 뷰모델 테스트 -> 네트워크 요청과 데이터 정제가 끝난 상황
// 온전히 UI간 통신 로직 구축만 검증하기 위한 테스트
// 불러온 데이터를 기반으로 인풋과 아웃풋 로직을 구축
final class MockPosePickUseCase: PosePickUseCase {
    var poseImage = PublishSubject<UIImage?>()
    
    func fetchPosePick(peopleCount: Int) {
        self.poseImage.onNext(ImageLiteral.imgInfo24)
    }
}
