//
//  MockPoseFeedRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockPoseFeedRepository: PoseFeedRepository {
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> {
        return Observable.just([
            Section(header: "", items: [
                PoseFeedPhotoCellViewModel(
                    image: ImageLiteral.imgInfo24,
                    poseId: 1,
                    bookmarkCheck: true
                )
            ]),
            Section(header: "", items: [
                PoseFeedPhotoCellViewModel(
                    image: ImageLiteral.imgInfo24,
                    poseId: 1,
                    bookmarkCheck: true
                )
            ])
        ])
    }
    
    
}