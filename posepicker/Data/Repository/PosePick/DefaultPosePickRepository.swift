//
//  DefaultPosePickRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DefaultPosePickRepository: PosePickRepository {
    
    let networkService: DefaultNetworkService
    
    init(networkService: DefaultNetworkService) {
        self.networkService = networkService
    }
    
    func fetchPose(peopleCount: Int) -> Observable<Pose> {
        return networkService.requestSingle(.retrievePosePick(peopleCount: peopleCount))
            .asObservable()
            .flatMapLatest { (posepick: Pose) -> Observable<Pose> in
                return BehaviorRelay<Pose>(value: posepick).asObservable()
            }
    }
}
