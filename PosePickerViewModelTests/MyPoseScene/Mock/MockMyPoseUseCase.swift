//
//  MockMyPoseUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

@testable import posepicker

final class MockMyPoseUseCase: MyPoseUseCase {
    var uploadedPoseCount = PublishSubject<String>()
    
    var savedPoseCount = PublishSubject<String>()
    
    func fetchPoseCount() {
        uploadedPoseCount.onNext("등록 10")
        savedPoseCount.onNext("저장 10")
    }
    
    
}
