//
//  MyPoseRepository.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift

protocol MyPoseRepository {
    func fetchPoseCount() -> Observable<PoseCount>
    func fetchUploadedContents(pageNumber: Int, pageSize: Int) -> Observable<[BookmarkFeedCellViewModel]>
    func isLastContents() -> Observable<Bool>
}
