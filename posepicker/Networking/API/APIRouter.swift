//
//  APIRouter.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import Foundation

import Alamofire

enum APIRouter: URLRequestConvertible {
    
    // 포즈 API
    case retrievePosePick(peopleCount: Int)
    case retrievePoseTalk
    case retrieveAllPoseFeed(pageNumber: Int, pageSize: Int)
    case retrieveFilteringPoseFeed(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int)
    case retrievePoseDetail(poseId: Int)
    
    // 유저 API
    case appleLogin(idToken: String)
    case kakaoLogin(authCode: String, email: String, kakaoId: Int64)
    case retrieveAuthoirzationCode
    case refreshToken
    
    // 북마크 API
    case registerBookmark(poseId: Int)
    case retrieveBookmarkFeed(pageNumber: Int, pageSize: Int)
    case deleteBookmark(poseId: Int)
    
    // MARK: - HttpMethod
    
    /// switch - self 구문으로 각 엔드포인트별 메서드 지정
    private var method: HTTPMethod {
        switch self {
        case .retrievePosePick:
            return .get
        case .retrievePoseTalk:
            return .get
        case .retrieveAllPoseFeed:
            return .get
        case .retrieveFilteringPoseFeed:
            return .get
        case .retrievePoseDetail:
            return .get
        case .appleLogin:
            return .get
        case .kakaoLogin:
            return .post
        case .retrieveAuthoirzationCode:
            return .get
        case .refreshToken:
            return .get
        case .registerBookmark:
            return .post
        case .retrieveBookmarkFeed:
            return .get
        case .deleteBookmark:
            return .delete
        }
    }
    
    // MARK: - Path
    
    /// switch - self 구문으로 각 엔드포인트별 URL Path 지정
    private var path: String {
        switch self {
        case .retrievePosePick(let peopleCount):
            return "/api/pose/pick/\(peopleCount)"
        case .retrievePoseTalk:
            return "/api/pose/talk"
        case .retrieveAllPoseFeed:
            return "/api/pose/all"
            // (peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int)
        case .retrieveFilteringPoseFeed:
            return "/api/pose"
        case .retrievePoseDetail(let poseId):
            return "/api/pose/\(poseId)"
        case .appleLogin:
            return "/api/users/login/ios/apple"
        case .kakaoLogin:
            return "/api/users/login/ios/kakao"
        case .retrieveAuthoirzationCode:
            return "/api/users/posepicker/token"
        case .refreshToken:
            return "/api/users/posepicker/token"
        case .registerBookmark:
            return "/api/bookmark"
        case .retrieveBookmarkFeed:
            return "/api/bookmark/feed"
        case .deleteBookmark:
            return "/api/bookmark"
        }
    }
    
    // MARK: - Parameters
    
    /// request body 정의
    /// 빈 body를 보낼때는 nil값 전달
    private var parameters: Parameters? {
        switch self {
        case .retrievePosePick:
            return nil
        case .retrievePoseTalk:
            return nil
        case .retrieveAllPoseFeed(let pageNumber, let pageSize):
            return [
                K.Parameters.pageNumber: pageNumber,
                K.Parameters.pageSize: pageSize
            ]
        case .retrieveFilteringPoseFeed(let peopleCount, let frameCount, let filterTags, let pageNumber):
            var tagString = ""
            filterTags.forEach { tagString += "\($0),"}
            var queryParams: Parameters = [
                K.Parameters.peopleCount: FilterTags.getNumberFromPeopleCountString(countString: peopleCount) ?? 0,
                K.Parameters.frameCount: FilterTags.getNumberFromFrameCountString(countString: frameCount) ?? 0,
                K.Parameters.tags: tagString,
                K.Parameters.pageNumber: pageNumber
            ]
            if tagString.isEmpty {
                queryParams.removeValue(forKey: K.Parameters.tags)
            }
            
            return queryParams
        case .retrievePoseDetail:
            return nil
        case .appleLogin(let idToken):
            return [
                K.Parameters.idToken: idToken
            ]
        case .kakaoLogin(let authCode, let email, let kakaoId):
            return [
                K.Parameters.email: email,
                K.Parameters.token: authCode,
                K.Parameters.uid: kakaoId
            ]
        case .retrieveAuthoirzationCode:
            return nil
        case .refreshToken:
            return nil
        case .registerBookmark(let poseId):
            return [
                K.Parameters.poseId: poseId
            ]
        case .retrieveBookmarkFeed(let pageNumber, let pageSize):
            return [
                K.Parameters.pageNumber: pageNumber,
                K.Parameters.pageSize: pageSize
            ]
        case .deleteBookmark(let poseId):
            return [
                K.Parameters.poseId: poseId
            ]
        }
        
    }
    
    // MARK: - URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = try K.baseUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        /// self의 method 속성을 참조
        urlRequest.httpMethod = method.rawValue
        
        /// 네트워크 통신 일반에 사용되는 헤더 기본추가
        urlRequest.setValue(K.ContentType.json.rawValue, forHTTPHeaderField: K.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(K.ContentType.json.rawValue, forHTTPHeaderField: K.HttpHeaderField.contentType.rawValue)
        
        /// 요청 바디 인코딩
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                // MARK: - POST요청에 쿼리 파라미터로 들어가는 API 예외처리
                if let urlString = urlRequest.url?.absoluteString,
                   urlString.contains("/api/bookmark") {
                    return URLEncoding(destination: .queryString)
                }
                return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: parameters)
    }
}
