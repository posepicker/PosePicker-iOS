//
//  DefaultPoseFeedRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/3/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxRelay

final class DefaultPoseFeedRepository: PoseFeedRepository {
    let networkService: NetworkService
    
    private let isLastFilteredContentsObservable = BehaviorRelay<Bool>(value: false)
    private let isLastRecommendedContentsObservable = BehaviorRelay<Bool>(value: false)
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func isLastFilteredContents() -> Observable<Bool> {
        return self.isLastFilteredContentsObservable.asObservable()
    }
    
    func isLastRecommendContents() -> Observable<Bool> {
        return self.isLastRecommendedContentsObservable.asObservable()
    }
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> {
        networkService
            .requestSingle(.retrieveFilteringPoseFeed(peopleCount: peopleCount, frameCount: frameCount, filterTags: filterTags, pageNumber: pageNumber))
            .asObservable()
            .withUnretained(self)
            .flatMapLatest { (owner, filteredContents: FilteredPose) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> in
                owner.isLastFilteredContentsObservable.accept(filteredContents.filteredContents?.last ?? true)
                owner.isLastRecommendedContentsObservable.accept(filteredContents.recommendedContents?.last ?? true)
                
                let filteredContentsExceptReportedData = owner.checkReportData(posefeed: filteredContents.filteredContents?.content ?? [])
                let recommendedContentsExceptReportedData = owner.checkReportData(posefeed: filteredContents.recommendedContents?.content ?? [])
                
                return Observable.combineLatest(
                    owner.cacheItem(for: filteredContentsExceptReportedData),
                    owner.cacheItem(for: recommendedContentsExceptReportedData)
                )
                .flatMapLatest { filterSection, recommendSection in
                    let relay = BehaviorRelay<[Section<PoseFeedPhotoCellViewModel>]>(value: [
                        Section(header: "", items: filterSection),
                        Section(header: "이런 포즈는 어때요?", items: recommendSection)
                    ])
                    
                    return relay.asObservable()
                }
            }
    }
    
    // true 리턴되어야 정상 응답처리된 것
    func bookmarkContent(poseId: Int, currentChecked: Bool) -> Observable<Bool> {
        if currentChecked {
            // 등록된 북마크 지우기
            // 응답으로 포즈아이디 -1
            return networkService
                .requestSingle(.deleteBookmark(poseId: poseId))
                .asObservable()
                .flatMapLatest { (response: BookmarkResponse) -> Observable<BookmarkResponse> in
                    let relay = BehaviorRelay<BookmarkResponse>(value: .init(poseId: -1))
                    relay.accept(response)
                    return relay.asObservable()
                }
                .map { $0.poseId == -1}
        } else {
            // 북마크 등록하기
            // 응답으로 포즈아이디
            return networkService
                .requestSingle(.registerBookmark(poseId: poseId))
                .asObservable()
                .flatMapLatest { (response: BookmarkResponse) -> Observable<BookmarkResponse> in
                    let relay = BehaviorRelay<BookmarkResponse>(value: .init(poseId: -1))
                    relay.accept(response)
                    return relay.asObservable()
                }
                .map { $0.poseId != -1}
        }
    }
    
    private func cacheItem(for contents: [Pose]) -> Observable<[PoseFeedPhotoCellViewModel]> {
        let viewModelObservable = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        
        contents.forEach { pose in
            let fixedWidth = (Int(UIScreen.main.bounds.width) - 56) / 2
            guard let width = pose.poseInfo.width,
                  let height = pose.poseInfo.height else {
                return
            }
            viewModelObservable.accept(
                viewModelObservable.value + [
                    .init(
                        poseId: pose.poseInfo.poseId ?? 0,
                        bookmarkCheck: pose.poseInfo.bookmarkCheck ?? false,
                        size: CGSize(
                            width: fixedWidth,
                            height: (height * fixedWidth) / width
                        ),
                        imageURL: pose.poseInfo.imageKey
                    )
                ]
            )
        }
        
        return viewModelObservable.skip(while: { $0.count < contents.count }).asObservable()
    }
    
    private func checkReportData(posefeed: [Pose]) -> [Pose] {
        var newPoseFeed = posefeed
        var allReportIds: [String] = []
        var posefeedIndicies: [Int] = []

        let dict = UserDefaults.standard.dictionaryRepresentation()

        for key in dict.keys {
            allReportIds.append(key)
        }

        newPoseFeed.enumerated().forEach { index, posepick in
            guard let poseId = posepick.poseInfo.poseId else { return }
            if posepick.poseInfo.source == "null" {
                posefeedIndicies.append(index)
            }
            if allReportIds.contains(where: { reportId in
                return reportId == "\(poseId)"
            }) {
                posefeedIndicies.append(index)
            }
        }

        newPoseFeed.remove(atOffsets: IndexSet(posefeedIndicies))

        return newPoseFeed
    }
}





