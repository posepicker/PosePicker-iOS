//
//  MockPosePickRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/31/24.
//

import UIKit
import RxSwift
import Kingfisher
import XCTest
@testable import posepicker

final class MockPosePickRepository: PosePickRepository {
    let imageDownloader: ImageDownloader
    
    init(imageDownloader: ImageDownloader = ImageDownloader.default) {
        self.imageDownloader = imageDownloader
    }
    
    func fetchPoseImage(peopleCount: Int) -> Observable<UIImage> {
        return Observable.just("TEST URL.com")
            .withUnretained(self)
            .flatMapLatest { (owner, imageURL) -> Observable<UIImage> in
                return owner.cacheItem(for: imageURL)
            }
    }
    
    private func cacheItem(for imageURL: String) -> Observable<UIImage> {
        return Observable.create { observer in
            ImageCache.default.retrieveImageInDiskCache(forKey: imageURL) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    if let image = value?.images?.first {
                        observer.onNext(image)
                    } else if let url = URL(string: imageURL) {
                        KingfisherManager.shared.retrieveImage(with: url, options: [.downloader(self.imageDownloader)]) { downloadResult in
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
            return Disposables.create {
                
            }
        }
    }
}
//{
//  "poseInfo": {
//    "bookmarkCheck": true,
//    "createdAt": "2024-03-31T14:03:02.592Z",
//    "frameCount": 0,
//    "imageKey": "string",
//    "peopleCount": 0,
//    "poseId": 0,
//    "source": "string",
//    "sourceUrl": "string",
//    "tagAttributes": "string",
//    "updatedAt": "2024-03-31T14:03:02.592Z",
//    "user": {
//      "email": "string",
//      "iosId": "string",
//      "loginType": "string",
//      "nickname": "string",
//      "uid": 0
//    }
//  }
//}
