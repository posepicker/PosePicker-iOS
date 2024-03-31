//
//  PosePickRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import Foundation
import RxSwift

protocol PosePickRepository {
    func fetchPose(peopleCount: Int) -> Observable<Pose>
}
