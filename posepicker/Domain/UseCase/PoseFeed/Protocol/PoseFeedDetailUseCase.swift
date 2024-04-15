//
//  PoseDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift
import RxRelay

protocol PoseDetailUseCase {
    var pose: PublishSubject<Pose> { get set }
    var tagItems: BehaviorRelay<[String]> { get set }
    var sourceUrl: BehaviorRelay<String> { get set }   // SNS URL
    var source: BehaviorRelay<String> { get set }      // SNS 아이디
    var bookmarkTaskCompleted: PublishSubject<Bool> { get set }
    
    func getTagsFromPoseInfo()
    func getSourceURLFromPoseInfo()
    func getSourceFromPoseInfo()
    func bookmarkContent(poseId: Int, currentChecked: Bool)
}
