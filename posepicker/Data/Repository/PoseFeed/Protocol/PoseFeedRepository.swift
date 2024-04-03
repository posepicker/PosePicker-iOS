//
//  PoseFeedRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
import RxSwift

protocol PoseFeedRepository {
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) -> Observable<[Section<PoseFeedPhotoCellViewModel>]>
}
