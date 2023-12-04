//
//  Constants.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation

struct K {
    /// API base URL
    static let baseUrl = "https://api-posepicker.site"
    
    /// 리퀘스트 바디 파라미터의 키값을 문자열로 사용할때 직접 추가
    struct Parameters {
        static let poseInfo = "poseInfo"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let imageKey = "imageKey"
        static let source = "source"
        static let sourceUrl = "sourceUrl"
        static let poseId = "poseId"
        static let peopleCount = "peopleCount"
        static let frameCount = "frameCount"
        static let tagAttributes = "tagAttributes"
        static let pageNumber = "pageNumber"
        static let pageSize = "pageSize"
        static let tags = "tags"
        static let idToken = "idToken"
        static let userId = "uid"
    }
    
    /// 키체인 키값 리스트
    struct KeychainKeyParameters {
        static let accessToken = "accesstoken"
        static let refreshToken = "refreshToken"
    }
    
    /// 헤더 필드
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }
    
    /// 컨텐츠 타입
    enum ContentType: String {
        case json = "application/json"
    }
}
