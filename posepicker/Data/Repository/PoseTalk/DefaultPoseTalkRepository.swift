//
//  DefaultPoseTalkRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation

import RxSwift

// 네트워크 객체 주입
final class DefaultPoseTalkRepository: PoseTalkRepository {
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseWord() -> Observable<String?> {
        return networkService.requestSingle(.retrievePoseTalk)
            .asObservable()
            .map { (poseTalk: PoseTalk) -> String? in
                return poseTalk.poseWord.content
            }
    }
}
