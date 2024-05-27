//
//  PoseDetailRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import UIKit
import RxSwift

protocol PoseDetailRepository {
    func fetchPoseInfo(poseId: Int) -> Observable<Pose>
    func cacheItem(for imageURL: String?) -> Observable<UIImage?>
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool>
}
