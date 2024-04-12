//
//  DefaultPoseUploadUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift

final class DefaultPoseUploadUseCase: PoseUploadUseCase {
    
    var disposeBag = DisposeBag()
    let poseUploadRepository: PoseUploadRepository
    
    init(poseUploadRepository: PoseUploadRepository) {
        self.poseUploadRepository = poseUploadRepository
    }
    
    var uploadCompletedEvent = PublishSubject<Pose>()
    
    func savePose(
        image: UIImage?,
        frameCount: String,
        peopleCount: String,
        source: String,
        sourceUrl: String,
        tag: String
    ) {
        poseUploadRepository
            .savePose(
                image: image,
                frameCount: frameCount,
                peopleCount: peopleCount,
                source: source,
                sourceUrl: sourceUrl,
                tag: tag
            )
            .subscribe(onNext: { [weak self] in
                self?.uploadCompletedEvent.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
