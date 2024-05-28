//
//  DefaultPosePickRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class DefaultPosePickRepository: PosePickRepository {
    
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchPoseImage(peopleCount: Int) -> Observable<UIImage?> {
        return networkService.requestSingle(.retrievePosePick(peopleCount: peopleCount))
            .asObservable()
            .flatMapLatest { (posepick: Pose) -> Observable<Pose?> in
                if posepick.poseInfo.poseId == nil { return BehaviorRelay<Pose?>(value: nil).asObservable() }
                return BehaviorRelay<Pose?>(value: posepick).asObservable()
            }
            .map { $0?.poseInfo.imageKey }
            .withUnretained(self)
            .flatMapLatest { (owner, imageURL) -> Observable<UIImage?> in
                return owner.cacheItem(for: imageURL)
            }
    }
    
    private func cacheItem(for imageURL: String?) -> Observable<UIImage?> {
        
        return Observable.create { observer in
            if let imageURL = imageURL {
                ImageCache.default.retrieveImage(forKey: imageURL) { result in
                    switch result {
                    case .success(let value):
                        if let image = value.image {
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
}
