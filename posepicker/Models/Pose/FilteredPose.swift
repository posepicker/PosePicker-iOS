//
//  FilteredPose.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/09.
//

import Foundation

struct FilteredPose: Codable {
    let filteredContents: FilteredContents
    let recommendation: Bool
    let recommendedContents: RecommendedContents?
}

struct FilteredContents: Codable {
    let content: [PosePick]
    let empty: Bool
    let first: Bool
    let last: Bool
    let number: Int
    let numberOfElements: Int
    let pageable: Page
    let size: Int
    let sort: Sort
}
