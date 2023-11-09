//
//  Page.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/09.
//

import Foundation

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
