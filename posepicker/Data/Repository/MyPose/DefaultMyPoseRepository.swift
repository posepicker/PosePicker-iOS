//
//  DefaultMyPoseRepository.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift

final class DefaultMyPoseRepository: MyPoseRepository {
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseCount() -> Observable<PoseCount> {
        networkService
            .requestSingle(.retrievePoseCount)
            .asObservable()
    }
}
