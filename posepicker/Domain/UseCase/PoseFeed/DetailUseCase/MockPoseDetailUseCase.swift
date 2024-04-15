//
//  MockPoseDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import Foundation
import RxSwift
import RxRelay

final class MockPoseDetailUseCase: PoseDetailUseCase {
    var pose = PublishSubject<Pose>()
    var tagItems = BehaviorRelay<[String]>(value: [])
    var sourceUrl = BehaviorRelay<String>(value: "")
    var source = BehaviorRelay<String>(value: "")
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    var poseValue: PoseInfo
    var tagItemsValue: [String]
    var sourceURLValue: String
    var sourceValue: String
    
    
    init(poseValue: PoseInfo, tagItemsValue: [String], sourceURLValue: String, sourceValue: String) {
        self.poseValue = poseValue
        self.tagItemsValue = tagItemsValue
        self.sourceURLValue = sourceURLValue
        self.sourceValue = sourceValue
    }
    
    func getTagsFromPoseInfo() {
        tagItems.accept(tagItemsValue)
    }
    
    func getSourceURLFromPoseInfo() {
        sourceUrl.accept(sourceURLValue)
    }
    
    func getSourceFromPoseInfo() {
        source.accept(poseValue.source ?? "")
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        bookmarkTaskCompleted.onNext(true)
    }
}
