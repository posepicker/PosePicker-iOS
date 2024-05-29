//
//  MockMyPoseRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockMyPoseRepository: MyPoseRepository {
    
    // 목업 데이터 10개
    let uploadedContents: [BookmarkFeedCellViewModel] = [
        .init(
            image: nil,
            poseId: 11,
            bookmarkCheck: false
        ),
        .init(
            image: ImageLiteral.imgAdd,
            poseId: 1,
            bookmarkCheck: false
        ),
        .init(
            image: nil,
            poseId: 2,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 3,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 4,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 5,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 6,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 7,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 8,
            bookmarkCheck: true
        ),
        .init(
            image: nil,
            poseId: 9,
            bookmarkCheck: true
        ),
    ]
    var isLast = false
    var numberOfBookmarkContents = 10
    
    func fetchPoseCount() -> Observable<PoseCount> {
        return .just(
            .init(
                bookmarkCount: numberOfBookmarkContents,
                uploadCount: uploadedContents.count
            )
        )
    }
    
    func fetchUploadedContents(pageNumber: Int, pageSize: Int) -> Observable<[BookmarkFeedCellViewModel]> {
        var array: [BookmarkFeedCellViewModel] = []
        if uploadedContents.count >= (pageNumber + 1) * pageSize {
            array = Array(uploadedContents[pageNumber * pageSize..<(pageNumber + 1) * pageSize])
        } else {
            array = Array(uploadedContents[pageNumber * pageSize..<uploadedContents.count])
            isLast = true
        }
        return .just(array)
    }
    
    func isLastContents() -> Observable<Bool> {
        return .just(isLast)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        if let index = uploadedContents.firstIndex(where: { $0.poseId.value == poseId }) {
            uploadedContents[index].bookmarkCheck.accept(!currentChecked)
            
            if currentChecked {
                numberOfBookmarkContents -= 1
            } else {
                numberOfBookmarkContents += 1
            }
            
            return .just(true)
        } else {
            return .just(false)
        }
    }
}
