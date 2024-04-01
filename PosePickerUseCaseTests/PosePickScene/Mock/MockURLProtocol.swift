//
//  MockURLProtocol.swift
//  posepicker
//
//  Created by 박경준 on 3/31/24.
//

import Foundation
import XCTest
@testable import posepicker

final class MockURLProtocol: URLProtocol {
    
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
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
        case empty
        case cacheImage
        
        var fileName: String {
            switch self {
            case .empty: return ""
            case .cacheImage: return "mock.png"
            }
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let response = setUpMockResponse()
        let data = setUpMockData()

        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        
        client?.urlProtocol(self, didLoad: data!)
        
        self.client?.urlProtocolDidFinishLoading(self)
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
    }
}
