//
//  MockBookmarkUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/3/24.
//

import Foundation
import RxRelay
import RxSwift
@testable import posepicker

final class MockBookmarkUseCase: BookmarkUseCase {
    var bookmarkContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
    
    var contentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var isLastPage = BehaviorRelay<Bool>(value: false)
    
    var contentLoaded = PublishSubject<Void>()
    
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int) {
        contentLoaded.onNext(())
        isLastPage.accept(false)
        let value = generateMockupData()
        
        if pageNumber == 0 {
            self.bookmarkContents.accept(value)
            
            self.contentSizes.accept(
                .init(
                    repeating: CGSize(width: 10, height: 10),
                    count: 5
                )
            )
        }
        else {
            self.contentSizes.accept(
                self.contentSizes.value + .init(
                repeating: CGSize(width: 10, height: 10),
                count: 5
            ))
            
            var contents = self.bookmarkContents.value
            contents += value
            self.bookmarkContents.accept(contents)
        }
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        if let item = bookmarkContents.value.first(where: { $0.poseId.value == poseId }) {
            item.bookmarkCheck.accept(!currentChecked)
            bookmarkTaskCompleted.onNext(true)
        } else {
            bookmarkTaskCompleted.onNext(false)
        }
    }
    
    func removeAllContents() {
        self.contentSizes.accept([])
        self.bookmarkContents.accept([])
    }
    
    private func generateMockupData() -> [BookmarkFeedCellViewModel] {
        return [
            .init(image: ImageLiteral.imgInfo24, poseId: 0, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 1, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 2, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 3, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 4, bookmarkCheck: true),
        ]
    }
}
