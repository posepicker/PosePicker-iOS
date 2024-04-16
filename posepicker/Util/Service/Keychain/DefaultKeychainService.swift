//
//  DefaultKeychainUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation

final class DefaultKeychainService: KeychainService {
    func save(key: String, value: String, itemClass: ItemClass = .password) {
        try? KeychainManager.shared.saveItem(value, itemClass: itemClass, key: key)
        try? KeychainManager.shared.updateItem(with: value, ofClass: itemClass, key: key)
    }
    
    func update(key: String, value: String, itemClass: ItemClass = .password) {
        try? KeychainManager.shared.updateItem(with: value, ofClass: itemClass, key: key)
    }
    
    func retrieve(key: String, itemClass: ItemClass = .password) -> String? {
        try? KeychainManager.shared.retrieveItem(ofClass: itemClass, key: key)
    }
    
    func delete(key: String, itemClass: ItemClass = .password) {
        try? KeychainManager.shared.deleteItem(ofClass: itemClass, key: key)
    }
    
    func removeAll() {
        KeychainManager.shared.removeAll()
    }
}
