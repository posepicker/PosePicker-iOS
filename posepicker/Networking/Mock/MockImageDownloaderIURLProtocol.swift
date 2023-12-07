//
//  MockImageDownloaderIURLProtocol.swift
//  posepicker
//
//  Created by 박경준 on 12/5/23.
//

import Foundation

final class MockImageDownloaderURLProtocol: URLProtocol {
    
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

extension MockImageDownloaderURLProtocol {
    
    static func responseWithFailure() {
        MockImageDownloaderURLProtocol.responseType = MockImageDownloaderURLProtocol.ResponseType.error(APIError.unknown)
    }
    
    static func responseWithStatusCode(code: Int) {
        MockImageDownloaderURLProtocol.responseType = MockImageDownloaderURLProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: K.baseUrl)!, statusCode: code, httpVersion: nil, headerFields: nil)!)
    }
    
    static func responseWithDTO(type: MockDTOType) {
        MockImageDownloaderURLProtocol.dtoType = type
    }
}


extension MockImageDownloaderURLProtocol {
    
    enum MockDTOType {
        case empty
        case cacheImage
        
        var fileName: String {
            switch self {
            case .empty: return ""
            case .cacheImage: return "image.png"
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
        switch MockImageDownloaderURLProtocol.responseType {
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
        let fileName: String = MockImageDownloaderURLProtocol.dtoType.fileName
       // 번들에 있는 json 파일로 Data 객체를 뽑아내는 과정.
        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return Data()
        }
        return try? Data(contentsOf: file)
    }
    
    override func stopLoading() {
    }
}
