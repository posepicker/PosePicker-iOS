//
//  KeychainUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation

protocol KeychainService {
    func save(key: String, value: String, itemClass: ItemClass)
    func update(key: String, value: String, itemClass: ItemClass)
    func retrieve(key: String, itemClass: ItemClass) -> String?
    func delete(key: String, itemClass: ItemClass)
    func removeAll()
}

extension KeychainService {
    func saveToken(_ token: Token) {
        save(key: K.Parameters.accessToken, value: token.accessToken, itemClass: .password)
        save(key: K.Parameters.refreshToken, value: token.accessToken, itemClass: .password)
    }
    
    func updateToken(_ token: Token) {
        update(key: K.Parameters.accessToken, value: token.accessToken, itemClass: .password)
        update(key: K.Parameters.refreshToken, value: token.refreshToken, itemClass: .password)
    }
    
    func deleteToken() {
        delete(key: K.Parameters.accessToken, itemClass: .password)
        delete(key: K.Parameters.refreshToken, itemClass: .password)
    }
    
    func saveEmail(_ email: String) {
        save(key: K.Parameters.email, value: email, itemClass: .password)
    }
}
