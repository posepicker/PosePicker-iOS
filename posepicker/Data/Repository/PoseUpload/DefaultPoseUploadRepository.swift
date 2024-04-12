//
//  DefaultPoseUploadRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift

final class DefaultPoseUploadRepository: PoseUploadRepository {
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func savePose(
        image: UIImage?,
        frameCount: String,
        peopleCount: String,
        source: String,
        sourceUrl: String,
        tag: String
    ) -> Observable<Pose> {
        networkService
            .requestMultipartSingle(
                .uploadPose(
                image: image,
                    frameCount: frameCount,
                    peopleCount: peopleCount,
                    source: source,
                    sourceUrl: sourceUrl,
                    tag: tag
                )
            )
            .asObservable()
            .flatMapLatest { (response: Pose) -> Observable<Pose> in
                return Observable.just(response)
            }
    }
}
