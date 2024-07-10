//
//  MockPoseFeedUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/4/24.
//

import Foundation
import RxSwift
import RxRelay

@testable import posepicker

final class MockPoseFeedUseCase: PoseFeedUseCase {
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        if let filteredContents = feedContents.value.first,
           let item = filteredContents.items.first(where: { $0.poseId.value == poseId }) {
            item.bookmarkCheck.accept(!currentChecked)
            bookmarkTaskCompleted.onNext(true)
        } else {
            bookmarkTaskCompleted.onNext(false)
        }
    }
    
    
    var feedContents = BehaviorRelay<[Section<PoseFeedPhotoCellViewModel>]>(value: [])
    
    var filterSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var recommendSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var isLastPage = BehaviorRelay<Bool>(value: false)
    
    var contentLoaded = PublishSubject<Void>()
    
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) {
        contentLoaded.onNext(())
        isLastPage.accept(false)
        let value = generateMockupData()
        
        if pageNumber == 0 { 
            self.feedContents.accept(value)
            
            self.filterSectionContentSizes.accept(
                .init(
                    repeating: CGSize(width: 10, height: 10),
                    count: 5
                )
            )
            self.recommendSectionContentSizes.accept(
                .init(
                    repeating: CGSize(width: 10, height: 10),
                    count: 5
                )
            )
        }
        else {
            self.filterSectionContentSizes.accept(
                self.filterSectionContentSizes.value + .init(
                repeating: CGSize(width: 10, height: 10),
                count: 5
            ))
            self.recommendSectionContentSizes.accept(
                self.recommendSectionContentSizes.value + .init(
                    repeating: CGSize(width: 10, height: 10),
                    count: 5
                ))
            
            var contents = self.feedContents.value
            contents[0].items += value[0].items
            contents[1].items += value[1].items
            self.feedContents.accept(contents)
        }
    }
    
    private func generateMockupData() -> [Section<PoseFeedPhotoCellViewModel>] {
        return [
            Section(header: "", items: [
                .init(poseId: 0, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 1, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 2, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 3, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 4, bookmarkCheck: true, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
        ]),
            Section(header: "", items: [
                .init(poseId: 5, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 6, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 7, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 8, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com"),
                .init(poseId: 9, bookmarkCheck: false, size: CGSize(width: 10, height: 20), imageURL: "https://url.com")
            ])
        ]
    }
    
    
}
