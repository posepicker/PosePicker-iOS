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
        contentLoaded.onNext(())
        isLastPage.accept(false)
        let value = generateMockupData()
        
        if pageNumber == 0 {
            self.uploadedContents.accept(value)
            
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
            
            var contents = self.uploadedContents.value
            contents += value
            self.uploadedContents.accept(contents)
        }
    }
    
    func removeAllContents() {
        self.uploadedContents.accept([])
        self.contentSizes.accept([])
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        if let item = uploadedContents.value.first(where: { $0.poseId.value == poseId }) {
            item.bookmarkCheck.accept(!currentChecked)
            bookmarkTaskCompleted.onNext(true)
        } else {
            bookmarkTaskCompleted.onNext(false)
        }
    }
    
    var uploadedPoseCount = PublishSubject<String>()
    
    var savedPoseCount = PublishSubject<String>()
    
    func fetchPoseCount() {
        uploadedPoseCount.onNext("등록 10")
        savedPoseCount.onNext("저장 10")
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
