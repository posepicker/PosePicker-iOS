//
//  DefaultPoseFeedDetailRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift

final class DefaultPoseFeedDetailRepository: PoseFeedDetailRepository {
    
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseInfo(poseId: Int) -> Observable<Pose> {
        networkService
            .requestSingle(.retrievePoseDetail(poseId: poseId))
            .asObservable()
    }
}
