//
//  PoseFeed.swift
//  posepicker
//
//  Created by Jun on 2023/11/05.
//

import Foundation

struct PoseFeed: Codable {
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

struct Page: Codable {
    let offset: Int
    let pageNumber: Int
    let pageSize: Int
    let paged: Bool
    let sort: Sort
    let unpaged: Bool
}

struct Sort: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}
