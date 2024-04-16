//
//  KeychainManager.swift
//  posepicker
//
//  Created by Jun on 2023/12/05.
//

import Foundation

import RxSwift

enum ItemClass: RawRepresentable {
    typealias RawValue = CFString
    
    case generic
    case password
    case certificate
    case cryptography
    case identity
    
    init?(rawValue: CFString) {
        switch rawValue {
        case kSecClassGenericPassword:
            self = .generic
        case kSecClassInternetPassword:
            self = .password
        case kSecClassCertificate:
            self = .certificate
        case kSecClassKey:
            self = .cryptography
        case kSecClassIdentity:
            self = .identity
        default:
            return nil
        }
    }
    
    var rawValue: CFString {
        switch self {
        case .generic:
            return kSecClassGenericPassword
        case .password:
            return kSecClassInternetPassword
        case .certificate:
            return kSecClassCertificate
        case .cryptography:
            return kSecClassKey
        case .identity:
            return kSecClassIdentity
        }
    }
}

enum KeychainError: Error {
    case invalidData
    case itemNotFound
    case duplicateItem
    case incorrectAttributeForClass
    case unexpected(OSStatus)
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .itemNotFound:
            return "Item not found"
        case .duplicateItem:
            return "Duplicate Item"
        case .incorrectAttributeForClass:
            return "Incorrect Attribute for Class"
        case .unexpected(let oSStatus):
            return "Unexpected error - \(oSStatus)"
        }
    }
}

typealias ItemAttributes = [CFString: Any]
typealias KeychainDictionary = [String: Any]

class KeychainManager {
    
    static let shared = KeychainManager() // 릴리즈용 매니저 객체
    static let mock = KeychainManager() // 목업 객체
    
    private init() {}
    
    private func convertError(_ error: OSStatus) -> KeychainError {
        switch error {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDataTooLarge:
            return .invalidData
        case errSecDuplicateItem:
            return .duplicateItem
        default:
            return .unexpected(error)
        }
    }
    
    func saveItem(
        _ item: String,
        itemClass: ItemClass,
        key: String,
        attributes: ItemAttributes? = nil) throws {
            // 1
            let itemData = try JSONEncoder().encode(item)
            
            // 2
            var query: [String: AnyObject] = [
                kSecClass as String: itemClass.rawValue,
                kSecAttrAccount as String: key as AnyObject,
                kSecValueData as String: itemData as AnyObject
            ]
            
            // 3
            if let itemAttributes = attributes {
                for(key, value) in itemAttributes {
                    query[key as String] = value as AnyObject
                }
            }
            
            // 4
            let result = SecItemAdd(query as CFDictionary, nil)
            
            // 5
            if result != errSecSuccess {
                throw convertError(result)
            }
        }
    
    func retrieveItem(
        ofClass itemClass: ItemClass,
        key: String, attributes:
        ItemAttributes? = nil) throws -> String {
            
            // 1
            var query: KeychainDictionary = [
                kSecClass as String: itemClass.rawValue,
                kSecAttrAccount as String: key as AnyObject,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true
            ]
            
            // 2
            if let itemAttributes = attributes {
                for(key, value) in itemAttributes {
                    query[key as String] = value as AnyObject
                }
            }
            
            // 3
            var item: CFTypeRef?
            
            // 4
            let result = SecItemCopyMatching(query as CFDictionary, &item)
            
            // 5
            if result != errSecSuccess {
                throw convertError(result)
            }
            
            // 6
            guard
                let keychainItem = item as? [String: Any],
                let data = keychainItem[kSecValueData as String] as? Data
            else {
                throw KeychainError.invalidData
            }
            
            // 7
            return try JSONDecoder().decode(String.self, from: data)
        }
    
    func updateItem(
        with item: String,
        ofClass itemClass: ItemClass,
        key: String,
        attributes: ItemAttributes? = nil) throws {
            
            let itemData = try JSONEncoder().encode(item)
            
            var query: KeychainDictionary = [
                kSecClass as String: itemClass.rawValue,
                kSecAttrAccount as String: key as AnyObject
            ]
            
            if let itemAttributes = attributes {
                for(key, value) in itemAttributes {
                    query[key as String] = value as AnyObject
                }
            }
            
            let attributesToUpdate: KeychainDictionary = [
                kSecValueData as String: itemData as AnyObject
            ]
            
            let result = SecItemUpdate(
                query as CFDictionary,
                attributesToUpdate as CFDictionary
            )
            
            if result != errSecSuccess {
                throw convertError(result)
            }
        }
    
    func deleteItem(
        ofClass itemClass: ItemClass,
        key: String, attributes:
        ItemAttributes? = nil) throws {
            
            var query: KeychainDictionary = [
                kSecClass as String: itemClass.rawValue,
                kSecAttrAccount as String: key as AnyObject
            ]
            
            if let itemAttributes = attributes {
                for(key, value) in itemAttributes {
                    query[key as String] = value as AnyObject
                }
            }
            
            let result = SecItemDelete(query as CFDictionary)
            if result != errSecSuccess {
                throw convertError(result)
            }
        }
    
    func removeAll() {
        let secItemClasses = [kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity]
        for secItemClass in secItemClasses {
            let dictionary = [kSecClass as String:secItemClass]
            SecItemDelete(dictionary as CFDictionary)
        }
    }
}

extension KeychainManager: ReactiveCompatible {}

extension Reactive where Base: KeychainManager {
    func saveItem(_ item: String, itemClass: ItemClass, key: String, attributes: ItemAttributes? = nil) -> Observable<Void> {
        return Observable.create({ observer -> Disposable in
            do {
                try self.base.saveItem(item, itemClass: itemClass, key: key)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                if let error = error as? KeychainError,
                   error.localizedDescription == "Duplicate Item" {
                    try! self.base.updateItem(with: item, ofClass: itemClass, key: key)
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    observer.onError(error)
                }
            }
            
            return Disposables.create { }
        })
    }
    
    func retrieveItem(ofClass itemClass: ItemClass, key: String, attributes: ItemAttributes? = nil) -> Observable<String> {
        return Observable.create({ observer -> Disposable in
            do {
                let result: String = try self.base.retrieveItem(ofClass: itemClass, key: key)
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create { }
        })
    }
    
    func updateItem(with item: String, ofClass itemClass: ItemClass, key: String, attributes: ItemAttributes? = nil) -> Observable<Void> {
        return Observable.create({ observer -> Disposable in
            do {
                try self.base.updateItem(with: item, ofClass: itemClass, key: key)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create { }
        })
    }
    
    func deleteItem(ofClass itemClass: ItemClass, key: String, attributes: ItemAttributes? = nil) -> Observable<Void> {
        return Observable.create({ observer -> Disposable in
            do {
                try self.base.deleteItem(ofClass: itemClass, key: key)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create { }
        })
    }
}

