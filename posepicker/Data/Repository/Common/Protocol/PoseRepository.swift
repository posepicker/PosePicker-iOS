//
//  ServerRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import UIKit

import RxSwift

protocol PoseRepository {
    // MARK: - 단일 포즈 SAVE/READ
    func fetchRandomPose(
        peopleCount: Int            // 인원 수
    ) -> Observable<Pose>
    func fetchPoseDetail(
        poseId: Int                 // 포즈 아이디
    ) -> Observable<Pose>
    func uploadPose(
        image: UIImage?,            // 포즈 이미지
        frameCount: String,         // 프레임 수
        peopleCount: String,        // 인원 수
        source: String,             // 이미지 출처 (인스타 아이디?)
        sourceUrl: String,          // 이미지 출처 URL
        tag: String                 // 태그 리스트, 배열을 쉼표 구분자로 파싱하여 전달
    ) -> Observable<Pose>
    
    // MARK: - 포즈톡 READ
    func fetchPoseWord(
    ) -> Observable<PoseTalk>       // 포즈톡은 파라미터 필요 없음
    
    // MARK: - 포즈피드 READ
    func fetchPoseFeed(
        peopleCount: String,        // 인원 수
        frameCount: String,         // 프레임 수
        filterTags: [String],       // 필터 태그
        pageNumber: Int             // 무한스크롤 페이징 값
    )
}
