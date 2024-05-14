//
//  APIError.swift
//  posepicker
//
//  Created by Jun on 2023/10/24.
//

import Foundation

enum APIError: Error, Equatable {
    case decode
    case http(status: Int)
    case unknown
}

/// API 에러 스트링으로 변환
extension APIError: CustomStringConvertible {
    var description: String {
        switch self {
        case .decode:
            return "Decode Error"
        case let .http(status):
            return "HTTP Error: \(status)"
        case .unknown:
            return "Unknown Error"
        }
    }
}
