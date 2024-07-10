//
//  MockPoseUploadUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/11/24.
//

import UIKit
import RxSwift

@testable import posepicker

final class MockPoseUploadUseCase: PoseUploadUseCase {
    var uploadCompletedEvent = PublishSubject<Pose>()
    
    func savePose(image: UIImage?, frameCount: String, peopleCount: String, source: String, sourceUrl: String, tag: String) {
        uploadCompletedEvent.onNext(
            .init(
                poseInfo:
                    .init(
                        createdAt: Date.now.toString(),
                        frameCount: 4,
                        imageKey: "https://imageURL.com",
                        peopleCount: 1,
                        poseId: 1,
                        source: source,
                        sourceUrl: sourceUrl,
                        tagAttributes: "친구,재미",
                        updatedAt: Date.now.toString(),
                        bookmarkCheck: true,
                        poseUploadUser: nil,
                        width: nil,
                        height: nil
                    )
            )
        )
    }
}
