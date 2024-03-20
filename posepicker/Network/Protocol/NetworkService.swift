//
//  APISession.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation
import RxSwift

protocol NetworkService {
    func requestSingle<T: Codable> (_ request: APIRouter) -> Single<T>
    func requestMultipartSingle<T: Codable>(_ request: APIRouter) -> Single<T>
}
