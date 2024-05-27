//
//  MockPoseDetailRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/18/24.
//

import UIKit
import RxSwift

@testable import posepicker

final class MockPoseDetailRepository: PoseDetailRepository {
    private var poseInfo: Pose = .init(
        poseInfo: .init(
            createdAt: "2024-04-18T05:37:55.974Z",
            frameCount: 8,
            imageKey: "www.S3.url",
            peopleCount: 4,
            poseId: 10,
            source: "@gangjuninggg",
            sourceUrl: "www.instagram.com",
            tagAttributes: "친구,자연스러움,가족,재미",
            updatedAt: "2024-04-18T05:37:55.974Z",
            bookmarkCheck: true,
            poseUploadUser: .init(
                uid: 0,
                nickname: "gangjuninggg",
                email: "rudwns3927@gmail.com",
                loginType: "kakao",
                iosId: "10"
            )
        )
    )
    
    private var nilPoseInfo: Pose = .init(
        poseInfo: .init(
            createdAt: nil,
            frameCount: nil,
            imageKey: "www.S3.url",
            peopleCount: nil,
            poseId: nil,
            source: nil,
            sourceUrl: nil,
            tagAttributes: nil,
            updatedAt: nil,
            bookmarkCheck: nil,
            poseUploadUser: nil
        )
    )
    
    private var hasPrefixPose: Pose = .init(
        poseInfo: .init(
            createdAt: "2024-04-18T05:37:55.974Z",
            frameCount: 8,
            imageKey: "www.S3.url",
            peopleCount: 4,
            poseId: 10,
            source: "@gangjuninggg",
            sourceUrl: "https://www.instagram.com",
            tagAttributes: "친구,자연스러움,가족,재미",
            updatedAt: "2024-04-18T05:37:55.974Z",
            bookmarkCheck: true,
            poseUploadUser: .init(
                uid: 0,
                nickname: "gangjuninggg",
                email: "rudwns3927@gmail.com",
                loginType: "kakao",
                iosId: "10"
            )
        )
    )
    
    var isNil: Bool
    var hasPrefix: Bool
    
    init(isNil: Bool, hasPrefix: Bool = false) {
        self.isNil = isNil
        self.hasPrefix = hasPrefix
    }
    
    func fetchPoseInfo(poseId: Int) -> Observable<Pose> {
        if self.hasPrefix {
            return Observable.just(self.hasPrefixPose)
        }
        return Observable.just(self.isNil ? self.nilPoseInfo : self.poseInfo)
    }
    
    func cacheItem(for imageURL: String?) -> Observable<UIImage?> {
        return Observable.just(nil)
    }
    
    /// 알 수 없는 이유로  북마크 대상 포즈 아이디가 요청 포즈 아이디와 매칭되지 않는 오류 -> 체크 실패 false 리턴
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        if !isNil {
            if let currentPoseId = self.poseInfo.poseInfo.poseId,
               currentPoseId == poseId {
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        } else {
            if let currentPoseId = self.nilPoseInfo.poseInfo.poseId,
               currentPoseId == poseId {
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        }
    }
}
