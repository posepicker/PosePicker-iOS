//
//  APIRouter.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit

import Alamofire

enum APIRouter: URLRequestConvertible {
    
    // 포즈 API
    case retrievePosePick(peopleCount: Int)
    case retrievePoseTalk
    case retrieveAllPoseFeed(pageNumber: Int, pageSize: Int)
    case retrieveFilteringPoseFeed(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int)
    case retrievePoseDetail(poseId: Int)
    case uploadPose(image: UIImage?, frameCount: String, peopleCount: String, source: String, sourceUrl: String, tag: String)
    case retrievePoseCount
    case retrieveUploadedPose(pageNumber: Int, pageSize: Int)
    
    // 유저 API
    case appleLogin(idToken: String)
    case kakaoLogin(authCode: String, email: String, kakaoId: Int64)
    case retrieveAuthoirzationCode
    case refreshToken(refreshToken : String)
    case logout(accessToken: String, refreshToken: String)
    case revoke(accessToken: String, refreshToken: String, withdrawalReason: String)
    
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
        case .uploadPose:
            return .post
        case .retrievePoseCount:
            return .get
        case .retrieveUploadedPose:
            return .get
        case .appleLogin:
            return .get
        case .kakaoLogin:
            return .post
        case .retrieveAuthoirzationCode:
            return .get
        case .refreshToken:
            return .post
        case .logout:
            return .patch
        case .revoke:
            return .patch
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
        case .uploadPose:
            return "/api/pose"
        case .retrievePoseCount:
            return "/api/pose/user/mypose"
        case .retrieveUploadedPose:
            return "/api/pose/user"
        case .appleLogin:
            return "/api/users/login/ios/apple"
        case .kakaoLogin:
            return "/api/users/login/ios/kakao"
        case .retrieveAuthoirzationCode:
            return "/api/users/posepicker/token"
        case .refreshToken:
            return "/api/auth/reissue-token"
        case .logout:
            return "/api/users/logout"
        case .revoke:
            return "/api/users/deleteAccount"
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
        case .uploadPose:
            return nil
        case .retrievePoseCount:
            return nil
        case .retrieveUploadedPose(let pageNumber, let pageSize):
            return [
                K.Parameters.pageNumber: pageNumber,
                K.Parameters.pageSize: pageSize
            ]
        case .appleLogin(let idToken):
            return [
                K.Parameters.idToken: idToken
            ]
        /// authCode: token
        /// uid: kakaoId
        /// email: email
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
        case .logout(let accessToken, let refreshToken):
            return [
                K.Parameters.accessToken: "Bearer " + accessToken,
                K.Parameters.refreshToken: "Bearer " + refreshToken
            ]
        case .revoke(let accessToken, let refreshToken, let withdrawalReason):
            return [
                K.Parameters.accessToken: "Bearer " + accessToken,
                K.Parameters.refreshToken: "Bearer " + refreshToken,
                K.Parameters.withdrawalReason: withdrawalReason
            ]
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
        urlRequest.setValue(K.ContentType.json.rawValue, forHTTPHeaderField: K.HttpHeaderField.contentType.rawValue)
        urlRequest.setValue(K.ContentType.json.rawValue, forHTTPHeaderField: K.HttpHeaderField.acceptType.rawValue)
        
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
        
        if let urlString = urlRequest.url?.absoluteString,
           urlString.contains("/api/pose/"),
           self.method == .post {
            return urlRequest
        }
        
        return try encoding.encode(urlRequest, with: parameters)
    }
    
    // MARK: - MultipartFormData
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
        case .uploadPose(let image, let frameCount, let peopleCount, let source, let sourceUrl, let tag):
            guard let frameCountData = frameCount.data(using: .utf8),
                  let peopleCountData = peopleCount.data(using: .utf8),
                  let sourceData = source.data(using: .utf8),
                  let sourceURLData = sourceUrl.data(using: .utf8),
                  let tagData = tag.data(using: .utf8) else {
                break
            }
            multipartFormData.append(frameCountData, withName: K.Parameters.frameCount)
            multipartFormData.append(peopleCountData, withName: K.Parameters.peopleCount)
            multipartFormData.append(sourceData, withName: K.Parameters.source)
            multipartFormData.append(sourceURLData, withName: K.Parameters.sourceUrl)
            multipartFormData.append(tagData, withName: K.Parameters.tags)
            
            // filename 지정 필요!
            if let size = image?.getSizeIn(.megabyte),
               size >= 10 {
                let compressedImage = image?.compressTo(9)
                if let imgData = compressedImage?.jpegData(compressionQuality: 1) {
                    multipartFormData.append(imgData, withName: K.Parameters.file, fileName: "\(image.hashValue).jpg", mimeType: "image/jpg")
                }
            } else {
                if let imgData = image?.jpegData(compressionQuality: 1) {
                    multipartFormData.append(imgData, withName: K.Parameters.file, fileName: "\(image.hashValue).jpg", mimeType: "image/jpg")
                }
            }
        default: ()
        }

        return multipartFormData
    }
}
