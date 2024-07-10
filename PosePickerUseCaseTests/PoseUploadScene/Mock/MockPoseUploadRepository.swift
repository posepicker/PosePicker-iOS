//
//  MockPoseUploadRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 5/29/24.
//

import UIKit
import RxSwift

@testable import posepicker

final class MockPoseUploadRepository: PoseUploadRepository {
    func savePose(image: UIImage?, frameCount: String, peopleCount: String, source: String, sourceUrl: String, tag: String) -> Observable<Pose> {
        return .just(
            .init(
                poseInfo: .init(
                    createdAt: Date.now.toString(),
                    frameCount: FrameCountTags.getNumberFromFrameCountString(countString: frameCount),
                    imageKey: "https://unsplash.com/ko/%EC%82%AC%EC%A7%84/dslr-%EC%B9%B4%EB%A9%94%EB%9D%BC%EB%A5%BC-%EB%93%A0-%EC%97%AC%EC%9E%90-e616t35Vbeg",
                    peopleCount: PeopleCountTags.getNumberFromPeopleCountString(countString: peopleCount),
                    poseId: 3,
                    source: source,
                    sourceUrl: sourceUrl,
                    tagAttributes: tag,
                    updatedAt: Date.now.toString(),
                    bookmarkCheck: false,
                    poseUploadUser: nil,
                    width: nil,
                    height: nil
                )
            )
        )
    }
}
