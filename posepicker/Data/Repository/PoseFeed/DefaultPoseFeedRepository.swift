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
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> {
        networkService
            .requestSingle(.retrieveFilteringPoseFeed(peopleCount: peopleCount, frameCount: frameCount, filterTags: filterTags, pageNumber: pageNumber))
            .asObservable()
            .withUnretained(self)
            .flatMapLatest { (owner, filteredContents: FilteredPose) -> Observable<[Section<PoseFeedPhotoCellViewModel>]> in
                
                let relay = PublishRelay<[Section<PoseFeedPhotoCellViewModel>]>()
                
                if let filteredPose = filteredContents.filteredContents {
                    let filteredSectionObservable = owner.cacheItem(for: filteredPose.content)
                    
                    if let recommendedPose = filteredContents.recommendedContents {
                        let recommendedSectionObservable = owner.cacheItem(for: recommendedPose.content)
                        
                        return Observable.combineLatest(filteredSectionObservable, recommendedSectionObservable)
                            .flatMapLatest { filterSection, recommendedSection in
                                relay.accept([
                                    Section(header: "", items: filterSection),
                                    Section(header: "이런 포즈는 어때요?", items: recommendedSection)
                                ])
                                return relay
                            }
                    }
                    
                    
                    return filteredSectionObservable
                        .flatMapLatest { filteredSection in
                            relay.accept([
                                Section(header: "", items: filteredSection)
                            ])
                            return relay
                        }
                }
                
                return relay.asObservable()
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
    
//    private func cacheItem(for contents: [Pose]) -> Observable<[PoseFeedPhotoCellViewModel]> {
//        return Observable.create { observer in
//            var posefeedPhotoCellViewModels: [PoseFeedPhotoCellViewModel] = []
//            contents.forEach { pose in
//                ImageCache.default.retrieveImageInDiskCache(forKey: pose.poseInfo.imageKey) { result in
//                    switch result {
//                    case .success(let value):
//                        if let image = value?.images?.first {
//                            let viewModel = PoseFeedPhotoCellViewModel(
//                                image: image,
//                                poseId: pose.poseInfo.poseId,
//                                bookmarkCheck: pose.poseInfo.bookmarkCheck ?? false
//                            )
//                            posefeedPhotoCellViewModels.append(viewModel)
//                        }
//                    case .failure(let error):
//                        observer.onError(error)
//                    }
//                }
//            }
//            return Disposables.create {
//                
//            }
//        }
//    }
}





