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

struct MeaninglessResponse: Codable {
    let entity: String
    let message: String
    let redirect: String
    let status: Int
}

struct LogoutResponse: Codable {
    let entity: String
    let message: String
    let status: Int
}
