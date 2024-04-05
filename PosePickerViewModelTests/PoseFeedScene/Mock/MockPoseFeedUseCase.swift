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
    
    var feedContents = BehaviorRelay<[Section<PoseFeedPhotoCellViewModel>]>(value: [])
    
    var filterSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var recommendSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    var isLastPage = BehaviorRelay<Bool>(value: false)
    
    var contentLoaded = PublishSubject<Void>()
    
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) {
        contentLoaded.onNext(())
        isLastPage.accept(false)
        let value = generateMockupData()
        
        if pageNumber == 0 { self.feedContents.accept(value) }
        else {
            var contents = self.feedContents.value
            contents[0].items += value[0].items
            contents[1].items += value[1].items
            self.feedContents.accept(contents)
        }
    }
    
    private func generateMockupData() -> [Section<PoseFeedPhotoCellViewModel>] {
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
        return [
            Section(header: "", items: [
            .init(image: ImageLiteral.imgInfo24, poseId: 0, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 1, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 2, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 3, bookmarkCheck: false),
            .init(image: ImageLiteral.imgInfo24, poseId: 4, bookmarkCheck: false),
        ]),
            Section(header: "", items: [
                .init(image: ImageLiteral.imgInfo24, poseId: 5, bookmarkCheck: false),
                .init(image: ImageLiteral.imgInfo24, poseId: 6, bookmarkCheck: false),
                .init(image: ImageLiteral.imgInfo24, poseId: 7, bookmarkCheck: false),
                .init(image: ImageLiteral.imgInfo24, poseId: 8, bookmarkCheck: false),
                .init(image: ImageLiteral.imgInfo24, poseId: 9, bookmarkCheck: false),
            ])
        ]
    }
    
    
}
