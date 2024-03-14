//
//  APIService.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation

import Alamofire
import RxSwift

protocol APIService {
    func requestSingle<T: Codable> (_ request: APIRouter) -> Single<T>
    func requestMultipartSingle<T: Codable>(_ request: APIRouter) -> Single<T>
}
