//
//  PoseInfo.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation

struct PoseInfo: Codable {
    let createdAt: String?
    let frameCount: Int?
    let imageKey: String
    let peopleCount: Int?
    let poseId: Int?
    let source: String?
    let sourceUrl: String?
    let tagAttributes: String?
    let updatedAt: String?
    let bookmarkCheck: Bool?
    let user: PoseUploadUser?
    
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
        case user
    }
    
    init(
        createdAt: String?,
        frameCount: Int?,
        imageKey: String,
        peopleCount: Int?,
        poseId: Int?,
        source: String?,
        sourceUrl: String?,
        tagAttributes: String?,
        updatedAt: String?,
        bookmarkCheck: Bool?,
        poseUploadUser: PoseUploadUser?
    ) {
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
        self.user = poseUploadUser
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.frameCount = try container.decodeIfPresent(Int.self, forKey: .frameCount)
        self.imageKey = try container.decode(String.self, forKey: .imageKey)
        self.peopleCount = try container.decodeIfPresent(Int.self, forKey: .peopleCount)
        self.poseId = try container.decodeIfPresent(Int.self, forKey: .poseId)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        self.tagAttributes = try container.decodeIfPresent(String.self, forKey: .tagAttributes)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.bookmarkCheck = try container.decodeIfPresent(Bool.self, forKey: .bookmarkCheck)
        self.user = try container.decodeIfPresent(PoseUploadUser.self, forKey: .user)
    }
}
