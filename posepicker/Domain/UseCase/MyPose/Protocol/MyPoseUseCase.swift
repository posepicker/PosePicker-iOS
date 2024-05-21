//
//  MyPoseUseCase.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

protocol MyPoseUseCase {
    var uploadedPoseCount: PublishSubject<String> { get set }
    var savedPoseCount: PublishSubject<String> { get set }
    
    var contentSizes: BehaviorRelay<[CGSize]> { get set }
    var isLastPage: BehaviorRelay<Bool> { get set }
    var contentLoaded: PublishSubject<Void> { get set }
    var uploadedContents: BehaviorRelay<[BookmarkFeedCellViewModel]> { get set }
    var bookmarkTaskCompleted: PublishSubject<Bool> { get set }
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int)
    func fetchPoseCount()
    func removeAllContents()
    func bookmarkContent(poseId: Int, currentChecked: Bool)
}
