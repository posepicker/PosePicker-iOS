//
//  MockPoseTalkRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/17/24.
//

import UIKit
import RxSwift
import Kingfisher
import XCTest
@testable import posepicker

final class MockPoseTalkRepository: PoseTalkRepository {
    func fetchPoseWord() -> Observable<String?> {
        return Observable.just("포즈톡 예시 키워드")
    }
}
