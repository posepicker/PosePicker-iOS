//
//  PosePick.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation

struct PosePick: Codable {
    let poseInfo: Pose
}

struct Pose: Codable {
    let createdAt: String?
    let frameCount: Int
    let imageKey: String
    let peopleCount: Int
    let poseId: Int
    let source: String
    let sourceUrl: String
    let tagAttributes: String
    let updatedAt: String?
}
