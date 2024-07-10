//
//  MockPoseFeedRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockPoseFeedRepository: PoseFeedRepository {
    private var sectionItems = [
        Section(header: "", items: [
            PoseFeedPhotoCellViewModel(
                poseId: 4,
                bookmarkCheck: true,
                size: CGSize(width: 10, height: 20),
                imageURL: "https://url.com"
            ),
            PoseFeedPhotoCellViewModel(
                poseId: 1,
                bookmarkCheck: true,
                size: CGSize(width: 10, height: 20),
                imageURL: "https://url.com"
            ),
        ]),
        Section(header: "", items: [
            PoseFeedPhotoCellViewModel(
                poseId: 3,
                bookmarkCheck: true,
                size: CGSize(width: 10, height: 20),
                imageURL: "https://url.com"
            ),
            PoseFeedPhotoCellViewModel(
                poseId: 2,
                bookmarkCheck: true,
                size: CGSize(width: 10, height: 20),
                imageURL: "https://url.com"
            )
        ])
    ]
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        // 불러온 섹션 아이템의 포즈 아이디값들이 북마크 체크 대상 아이디값을 포함하고 있을때 -> 북마크 등록 및 삭제 정상처리
        // 포즈 아이디가 없는 잘못된 요청시 -> false 리턴
        if let _ = sectionItems.firstIndex(where: { section in
            if let _ = section.items.firstIndex(where: { item in
                item.poseId.value == poseId
            }) {
                return true
            } else {
                return false
            }
        }) {
            return Observable.just(true)
        } else {
            return Observable.just(false)
        }
    }
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> {
        return Observable.just(self.sectionItems)
    }
    
    func isLastFilteredContents() -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func isLastRecommendContents() -> Observable<Bool> {
        return Observable.just(true)
    }
}
