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
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
    }
}
