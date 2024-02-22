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
           let accessToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.accessToken),
           let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.refreshToken) {
            
            if url.absoluteString.contains("/api/pose") || url.absoluteString.contains("/api/pose/all") || url.absoluteString.contains("/api/bookmark") {
                var urlRequest = urlRequest
                urlRequest.headers.add(.authorization(bearerToken: accessToken))
                completion(.success(urlRequest))
                return
            } else if url.absoluteString.contains("/api/auth/reissue-token") {
                var urlRequest = urlRequest
                urlRequest.headers.add(.authorization(bearerToken: refreshToken))
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
        
        // 401이면서 리프레시 토큰이 만료된 상태일때
        if let url = response.url,
           url.absoluteString.contains("/api/auth/reissue-token") {
            KeychainManager.shared.removeAll()
            // 세션만료 ALERT
            completion(.doNotRetry)
            return
        }
        
        guard let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.KeychainKeyParameters.refreshToken) else {
            completion(.doNotRetry)
            return
        }
        
        let refreshTokenObservable: Single<Token> = apiSession.requestSingle(.refreshToken(refreshToken: refreshToken))
        
        refreshTokenObservable
            .asObservable()
            .subscribe(onNext: { token in
                KeychainManager.shared.removeAll()
                try? KeychainManager.shared.saveItem(token.accessToken, itemClass: .password, key: K.KeychainKeyParameters.accessToken)
                try? KeychainManager.shared.saveItem(token.refreshToken, itemClass: .password, key: K.KeychainKeyParameters.refreshToken)
                completion(.retry)
            })
            .disposed(by: disposeBag)
    }
}
