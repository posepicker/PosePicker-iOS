//
//  User.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import Foundation

struct PosePickerUser: Codable {
    let email: String
    let id: Int
    let nickname: String
    let token: Token
}
