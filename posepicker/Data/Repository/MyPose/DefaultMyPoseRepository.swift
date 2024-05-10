//
//  DefaultMyPoseRepository.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay
import Kingfisher

final class DefaultMyPoseRepository: MyPoseRepository {
    let networkService: NetworkService
    private let isLastContentsObservable = BehaviorRelay<Bool>(value: false)
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseCount() -> Observable<PoseCount> {
        networkService
            .requestSingle(.retrievePoseCount)
            .asObservable()
    }
    
    func isLastContents() -> Observable<Bool> {
        return self.isLastContentsObservable.asObservable()
    }
    
    func fetchUploadedContents(pageNumber: Int, pageSize: Int = 8) -> Observable<[BookmarkFeedCellViewModel]> {
        return networkService
            .requestSingle(.retrieveUploadedPose(pageNumber: pageNumber, pageSize: pageSize))
            .asObservable()
            .withUnretained(self)
            .flatMapLatest { (owner, contents: PoseFeed) -> Observable<[BookmarkFeedCellViewModel]> in
                let contentsExceptReportedData = owner.checkReportData(posefeed: contents.content)
                owner.isLastContentsObservable.accept(contents.last)
                return owner.cacheItem(for: contentsExceptReportedData)
            }
            .flatMapLatest { filterSection in
                let relay = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: filterSection)
                
                return relay.asObservable()
            }
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
            if allReportIds.contains(where: { reportId in
                return reportId == "\(poseId)"
            }) {
                posefeedIndicies.append(index)
            }
        }

        newPoseFeed.remove(atOffsets: IndexSet(posefeedIndicies))

        return newPoseFeed
    }
    
    private func cacheItem(for contents: [Pose]) -> Observable<[BookmarkFeedCellViewModel]> {
        let viewModelObservable = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        
        contents.forEach { pose in
            ImageCache.default.retrieveImageInDiskCache(forKey: pose.poseInfo.imageKey) { result in
                switch result {
                case .success(let value):
                    if let image = value?.images?.first {
                        let viewModel = BookmarkFeedCellViewModel(
                            image: image,
                            poseId: pose.poseInfo.poseId ?? 0,
                            bookmarkCheck: pose.poseInfo.bookmarkCheck ?? false
                        )
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else if let url = URL(string: pose.poseInfo.imageKey) {
                        KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                            switch downloadResult {
                            case .success(let downloaded):
                                let viewModel = BookmarkFeedCellViewModel(
                                    image: downloaded.image,
                                    poseId: pose.poseInfo.poseId ?? 0,
                                    bookmarkCheck: pose.poseInfo.bookmarkCheck ?? false)
                                viewModelObservable.accept(viewModelObservable.value + [viewModel])
                            case .failure:
                                return
                            }
                        }
                    }
                case .failure:
                    return
                }
            }
        }
        
        return viewModelObservable.skip(while: { $0.count < contents.count }).asObservable()
    }
}
