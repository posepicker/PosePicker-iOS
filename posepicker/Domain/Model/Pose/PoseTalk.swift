//
//  PoseTalk.swift
//  posepicker
//
//  Created by Jun on 2023/11/01.
//

import Foundation

struct PoseTalk: Codable {
    let poseWord: PoseWord
}

struct PoseWord: Codable {
    let content: String
    let createdAt: String
    let updatedAt: String
    let wordId: Int
}
