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
                return Observable.combineLatest(
                    owner.cacheItem(for: filteredContents.filteredContents?.content ?? []),
                    owner.cacheItem(for: filteredContents.recommendedContents?.content ?? [])
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
    
    private func cacheItem(for contents: [Pose]) -> Observable<[PoseFeedPhotoCellViewModel]> {
        let viewModelObservable = BehaviorRelay<[PoseFeedPhotoCellViewModel]>(value: [])
        
        contents.forEach { pose in
            ImageCache.default.retrieveImageInDiskCache(forKey: pose.poseInfo.imageKey) { result in
                switch result {
                case .success(let value):
                    if let image = value?.images?.first {
                        let viewModel = PoseFeedPhotoCellViewModel(
                            image: image,
                            poseId: pose.poseInfo.poseId,
                            bookmarkCheck: pose.poseInfo.bookmarkCheck ?? false
                        )
                        viewModelObservable.accept(viewModelObservable.value + [viewModel])
                    } else if let url = URL(string: pose.poseInfo.imageKey) {
                        KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                            switch downloadResult {
                            case .success(let downloaded):
                                let viewModel = PoseFeedPhotoCellViewModel(
                                    image: downloaded.image,
                                    poseId: pose.poseInfo.poseId,
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





