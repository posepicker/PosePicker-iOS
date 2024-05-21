//
//  BoomarkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxRelay
import RxSwift

protocol BookmarkUseCase {
    var bookmarkContents: BehaviorRelay<[BookmarkFeedCellViewModel]> { get set }
    var contentSizes: BehaviorRelay<[CGSize]> { get set }
    var isLastPage: BehaviorRelay<Bool> { get set }
    var contentLoaded: PublishSubject<Void> { get set }
    var bookmarkTaskCompleted: PublishSubject<Bool> { get set }
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int)
    func bookmarkContent(poseId: Int, currentChecked: Bool)
    func removeAllContents()
}
