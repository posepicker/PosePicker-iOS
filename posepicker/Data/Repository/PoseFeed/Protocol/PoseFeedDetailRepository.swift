//
//  PoseFeedDetailRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift

protocol PoseFeedDetailRepository {
    func fetchPoseInfo(poseId: Int) -> Observable<Pose>
}
