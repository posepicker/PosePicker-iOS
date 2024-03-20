//
//  PosePick.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation
import Alamofire

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
    let tagAttributes: String?
    let updatedAt: String?
    let bookmarkCheck: Bool?
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case frameCount
        case imageKey
        case peopleCount
        case poseId
        case source
        case sourceUrl
        case tagAttributes
        case updatedAt
        case bookmarkCheck
    }
    
    init(createdAt: String?, frameCount: Int, imageKey: String, peopleCount: Int, poseId: Int, source: String, sourceUrl: String, tagAttributes: String?, updatedAt: String?, bookmarkCheck: Bool?) {
        self.createdAt = createdAt
        self.frameCount = frameCount
        self.imageKey = imageKey
        self.peopleCount = peopleCount
        self.poseId = poseId
        self.source = source
        self.sourceUrl = sourceUrl
        self.tagAttributes = tagAttributes
        self.updatedAt = updatedAt
        self.bookmarkCheck = bookmarkCheck
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.frameCount = try container.decode(Int.self, forKey: .frameCount)
        self.imageKey = try container.decode(String.self, forKey: .imageKey)
        self.peopleCount = try container.decode(Int.self, forKey: .peopleCount)
        self.poseId = try container.decode(Int.self, forKey: .poseId)
        self.source = try container.decode(String.self, forKey: .source)
        self.sourceUrl = try container.decode(String.self, forKey: .sourceUrl)
        self.tagAttributes = try container.decodeIfPresent(String.self, forKey: .tagAttributes)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.bookmarkCheck = try container.decodeIfPresent(Bool.self, forKey: .bookmarkCheck)
    }
}
