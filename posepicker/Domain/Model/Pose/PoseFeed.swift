//
//  PoseFeed.swift
//  posepicker
//
//  Created by Jun on 2023/11/05.
//

import Foundation

struct PoseFeed: Codable {
    let content: [Pose]
    let empty: Bool
    let first: Bool
    let last: Bool
    let number: Int
    let numberOfElements: Int
    let pageable: Page
    let size: Int
    let sort: Sort
}
