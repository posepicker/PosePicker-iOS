//
//  DefaultPoseDetailRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxRelay

final class DefaultPoseDetailRepository: PoseDetailRepository {
    
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseInfo(poseId: Int) -> Observable<Pose> {
        networkService
            .requestSingle(.retrievePoseDetail(poseId: poseId))
            .asObservable()
    }
    
    func cacheItem(for imageURL: String?) -> Observable<UIImage?> {
        return Observable.create { observer in
            if let imageURL = imageURL {
                ImageCache.default.retrieveImageInDiskCache(forKey: imageURL) { result in
                    switch result {
                    case .success(let value):
                        if let image = value?.images?.first {
                            observer.onNext(image)
                        } else if let url = URL(string: imageURL) {
                            KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                                switch downloadResult {
                                case .success(let downloaded):
                                    observer.onNext(downloaded.image)
                                case .failure(let error):
                                    observer.onError(error)
                                }
                            }
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            } else {
                observer.onNext(nil)
            }
            
            return Disposables.create {
                
            }
        }
    }
    
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
}
