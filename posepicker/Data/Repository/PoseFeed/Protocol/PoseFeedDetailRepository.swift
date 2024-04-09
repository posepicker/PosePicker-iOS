//
//  PoseDetailRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift

protocol PoseDetailRepository {
    func fetchPoseInfo(poseId: Int) -> Observable<Pose>
}
