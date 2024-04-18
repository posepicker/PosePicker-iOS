//
//  MockPoseDetailRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/18/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockPoseDetailRepository: PoseDetailRepository {
    func fetchPoseInfo(poseId: Int) -> Observable<posepicker.Pose> {
        return .empty()
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        return .empty()
    }
}
