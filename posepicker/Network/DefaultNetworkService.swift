//
//  DefaultNetworkService.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation

import Alamofire
import RxSwift
import RxCocoa

// 세션 의존성 주입
struct DefaultNetworkService: NetworkService {
    
    private let session: Session
    
    init(session: Session = Session(configuration: URLSessionConfiguration.af.default, eventMonitors: [APIEventLogger()])) {
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
    
    /// Single Trait 멀티파트 통신
    func requestMultipartSingle<T: Codable>(_ request: APIRouter) -> Single<T> {
        return Single<T>.create { observer -> Disposable in
            let request = session.upload(multipartFormData: request.multipartFormData, with: request, interceptor: APIInterceptor())
                .uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .validate(statusCode: 200..<300)
                .responseDecodable { (response: DataResponse<T, AFError>) in
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
