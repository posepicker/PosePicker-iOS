//
//  Token.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import Foundation

struct Token: Codable {
    let accessToken: String
    let expiresIn: Int
    let grantType: String
    let refreshToken: String
}

struct RefreshedToken: Codable {
    let token: String
}
