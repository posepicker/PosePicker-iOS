//
//  MockPoseTalkUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/31/24.
//

import Foundation
import RxSwift
import RxRelay

@testable import posepicker

final class MockPoseTalkUseCase: PoseTalkUseCase {
    var poseWord = BehaviorRelay<String?>(value: nil)
    var isLoading = BehaviorRelay<Bool>(value: true)
    
    func fetchPoseTalk() {
        poseWord.accept("고개들어 하늘 보라")
    }
}
