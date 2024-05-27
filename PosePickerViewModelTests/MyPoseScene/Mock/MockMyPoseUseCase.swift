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
    var contentSizes = BehaviorRelay<[CGSize]>(value: [])
    var isLastPage = BehaviorRelay<Bool>(value: false)
    var contentLoaded = PublishSubject<Void>()
    var uploadedContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int) {
        
    }
    
    func removeAllContents() {
        
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        
    }
    
    var uploadedPoseCount = PublishSubject<String>()
    
    var savedPoseCount = PublishSubject<String>()
    
    func fetchPoseCount() {
        uploadedPoseCount.onNext("등록 10")
        savedPoseCount.onNext("저장 10")
    }
    
    
}
