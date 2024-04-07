//
//  PoseDTO.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation

struct PoseInfoDTO: Codable {
    private let bookmarkCheck: Bool
    private let createdAt: String
    private let frameCount: Int
    private let imaegKey: String
    private let peopleCount: Int
    private let poseId: Int
    private let source: String
    private let sourceUrl: String
    private let tagAttributes: String
    private let updatedAt: String
    private let user: PoseUploadUser
}
