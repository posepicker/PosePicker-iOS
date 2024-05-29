//
//  MockBookmarkRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockBookmarkRepository: BookmarkRepository {
    private var bookmarkContents: [BookmarkFeedCellViewModel] = [
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
    private var isLast = false
    
    func fetchBookmarkContents(pageNumber: Int, pageSize: Int) -> Observable<[posepicker.BookmarkFeedCellViewModel]> {
        var array: [BookmarkFeedCellViewModel] = []
        if bookmarkContents.count >= (pageNumber + 1) * pageSize {
            array = Array(bookmarkContents[pageNumber * pageSize..<(pageNumber + 1) * pageSize])
        } else {
            array = Array(bookmarkContents[pageNumber * pageSize..<bookmarkContents.count])
            isLast = true
        }
        return .just(array)
    }
    
    func isLastContents() -> Observable<Bool> {
        return Observable.just(self.isLast)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        if let index = bookmarkContents.firstIndex(where: { $0.poseId.value == poseId }) {
            bookmarkContents[index].bookmarkCheck.accept(!currentChecked)
            
            return .just(true)
        } else {
            return .just(false)
        }
    }
}
