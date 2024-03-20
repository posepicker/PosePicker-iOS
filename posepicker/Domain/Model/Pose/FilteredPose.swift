//
//  FilteredPose.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/09.
//

import Foundation

struct FilteredPose: Codable {
    let filteredContents: PoseFeed?
    let recommendation: Bool
    let recommendedContents: PoseFeed?
}
