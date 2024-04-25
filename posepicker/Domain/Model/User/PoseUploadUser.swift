//
//  PoseUploadUser.swift
//  posepicker
//
//  Created by 박경준 on 4/2/24.
//

import Foundation

struct PoseUploadUser: Codable {
    let uid: Int
    let nickname: String
    let email: String
    let loginType: String
    let iosId: String?
}
