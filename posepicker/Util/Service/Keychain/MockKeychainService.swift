//
//  MockKeychainService.swift
//  posepicker
//
//  Created by 박경준 on 5/28/24.
//

import Foundation

final class MockKeychainService: KeychainService {
    func save(key: String, value: String, itemClass: ItemClass = .password) {
        try? KeychainManager.mock.saveItem(value, itemClass: itemClass, key: key)
        try? KeychainManager.mock.updateItem(with: value, ofClass: itemClass, key: key)
    }
    
    func update(key: String, value: String, itemClass: ItemClass = .password) {
        try? KeychainManager.mock.updateItem(with: value, ofClass: itemClass, key: key)
    }
    
    func retrieve(key: String, itemClass: ItemClass = .password) -> String? {
        try? KeychainManager.mock.retrieveItem(ofClass: itemClass, key: key)
    }
    
    func delete(key: String, itemClass: ItemClass = .password) {
        try? KeychainManager.mock.deleteItem(ofClass: itemClass, key: key)
    }
    
    func removeAll() {
        KeychainManager.mock.removeAll()
    }
}
