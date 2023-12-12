//
//  APISession.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation

import Alamofire
import RxSwift

// 세션 의존성 주입
struct APISession: APIService {
    
    private let session: Session
    
    init(session: Session = Session(configuration: URLSessionConfiguration.af.default, eventMonitors: [])) {
        self.session = session
    }
    
    /// Single Trait으로 데이터 요청
    func requestSingle<T: Codable>(_ request: APIRouter) -> Single<T> {
        return Single<T>.create { observer -> Disposable in
                let request = session.request(request, interceptor: APIInterceptor()).responseDecodable { (response: DataResponse<T, AFError>) in
                    guard let statusCode = response.response?.statusCode else {
                        observer(.failure(APIError.unknown))
                        return
                    }

                    guard (200 ... 399).contains(statusCode) else {
                        observer(.failure(APIError.http(status: statusCode)))
                        return
                    }

                    guard let decoded = response.data?.decode(T.self) else {
                        observer(.failure(APIError.decode))
                        return
                    }

                    observer(.success(decoded))
                    return
                }

                return Disposables.create {
                    request.cancel()
                }
            }
    }
}
