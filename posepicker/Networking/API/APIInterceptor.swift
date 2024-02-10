//
//  APIInterceptor.swift
//  posepicker
//
//  Created by Jun on 2023/10/24.
//

import Foundation

import Alamofire
import RxSwift

class APIInterceptor: RequestInterceptor {
    var disposeBag = DisposeBag()
    var apiSession: APIService = APISession()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        if let url = urlRequest.url,
           let accessToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.accessToken) {
            
            if url.absoluteString.contains("/api/pose") || url.absoluteString.contains("/api/pose/all") || url.absoluteString.contains("/api/bookmark") {
                var urlRequest = urlRequest
                urlRequest.headers.add(.authorization(bearerToken: accessToken))
                completion(.success(urlRequest))
                return
            }
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        completion(.doNotRetry)
        return
//        KeychainManager.shared.removeAll()
//        completion(.retry)
    }
}
