//
//  MockPoseTalkUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/31/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockPoseTalkUseCase: PoseTalkUseCase {
    var poseWord = PublishSubject<String?>()
    
    func fetchPoseTalk() {
        poseWord.onNext("고개들어 하늘 보라")
    }
}
