//
//  Constants.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation

struct K {
    /// API base URL
    static let baseUrl = "https://api.posepicker.site"
    
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
        static let email = "email"
        static let token = "token"
        static let uid = "uid"
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let file = "file"
        static let withdrawalReason = "withdrawalReason"
    }
    
    /// 키체인 키값 리스트
    struct KeychainKeyParameters {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    /// UserDefaults 키값
    struct UserDefaultsKey {
        static let reportId = "reportId"
    }
    
    /// UserDefaults 로그인 방법 분류
    struct SocialLogin {
        static let socialLogin = "social-login"
        
        static let apple = "apple"
        static let kakao = "kakao"
        static let isLoggedIn = "isLoggedIn"
    }
    
    /// 헤더 필드
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case multipartFormData = "multipart/form-data"
    }
    
    /// 컨텐츠 타입
    enum ContentType: String {
        case json = "application/json"
        case all = "*/*"
    }
}
