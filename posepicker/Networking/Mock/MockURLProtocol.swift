//
//  MockURLProtocol.swift
//  posepicker
//
//  Created by 박경준 on 12/2/23.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    private(set) var activeTask: URLSessionTask?
    
    enum ResponseType {
        case error(APIError)
        case success(HTTPURLResponse)
    }
    
    static var responseType: ResponseType!
    static var dtoType: MockDTOType!
}

extension MockURLProtocol {
    
    static func responseWithFailure() {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.error(APIError.unknown)
    }
    
    static func responseWithStatusCode(code: Int) {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: K.baseUrl)!, statusCode: code, httpVersion: nil, headerFields: nil)!)
    }
    
    static func responseWithDTO(type: MockDTOType) {
        MockURLProtocol.dtoType = type
    }
}


extension MockURLProtocol {
    
    enum MockDTOType {
        case posepick
        case starred
        case user
        case empty
        case oauth
        case oauthBadRequest
        case oauthRedirectURLMismatch
        case oauthIncorrectClientCredentials
        
        var fileName: String {
            switch self {
            case .posepick: return "PosePick.json"
            case .starred: return "GithubAPI_Response_Starred.json"
            case .user: return "GithubAPI_Response_User.json"
            case .empty: return ""
            case .oauth: return  "GithubOAuth_Response.json"
            case .oauthBadRequest: return "GithubOAuth_BedVerificationCode.json"
            case .oauthRedirectURLMismatch: return "GithubOAuth_RedirectURIMismatch.json"
            case .oauthIncorrectClientCredentials: return "GithubOAuth_IncorrectClientCredentials.json"
            }
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override func startLoading() {
        let response = setUpMockResponse()
        let data = setUpMockData()
        
        // 가짜 리스폰스 내보내기
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        
        // 가짜 데이터 내보내기
        client?.urlProtocol(self, didLoad: data!)
        
        // 로드 끝났어!!!!
        self.client?.urlProtocolDidFinishLoading(self)
        activeTask = session.dataTask(with: request.urlRequest!)
        activeTask?.cancel()
    }
    
    private func setUpMockResponse() -> HTTPURLResponse? {
        var response: HTTPURLResponse?
        switch MockURLProtocol.responseType {
        case .error(let error)?:
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let newResponse)?:
            response = newResponse
        default:
            fatalError("No fake responses found.")
        }
        return response!
    }
    
    private func setUpMockData() -> Data? {
        let fileName: String = MockURLProtocol.dtoType.fileName

       // 번들에 있는 json 파일로 Data 객체를 뽑아내는 과정.
        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return Data()
        }
        return try? Data(contentsOf: file)
    }
    
    override func stopLoading() {
        activeTask?.cancel()
    }
}
