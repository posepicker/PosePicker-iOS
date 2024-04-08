//
//  PoseFeedDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift
import RxRelay

protocol PoseFeedDetailUseCase {
    var pose: PublishSubject<Pose> { get set }
    var tagItems: BehaviorRelay<[String]> { get set }
    var sourceUrl: PublishSubject<String> { get set }
    
    func getTagsFromPoseInfo()
    func getSourceURLFrom()
}
