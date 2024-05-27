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
    func fetchPoseImage(peopleCount: Int) -> Observable<UIImage?> {
        return Observable.just("https://posepicker-image.s3.ap-northeast-2.amazonaws.com/6fc77625e557babd80e8e389baf798c12a8d210d9c148de6595962923d81481b.jpg")
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .flatMapLatest { (owner, imageURL) -> Observable<UIImage?> in
                return owner.cacheItem(for: imageURL)
            }
    }
    
    let imageDownloader: ImageDownloader
    
    private var isAccessedToCacheFirst = true
    
    init(imageDownloader: ImageDownloader = ImageDownloader.default) {
        self.imageDownloader = imageDownloader
    }
    
    private func cacheItem(for imageURL: String) -> Observable<UIImage?> {
        if self.isAccessedToCacheFirst && ImageCache.default.isCached(forKey: imageURL) {
            print("=====")
            print("first & isCached")
            self.isAccessedToCacheFirst = false
            ImageCache.default.removeImage(forKey: imageURL)
            print("=====")
        }
        
        return Observable.create { observer in
            ImageCache.default.retrieveImage(forKey: imageURL, callbackQueue: .mainAsync) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    print("mock value!!: \(value)")
                    if let image = value.image {
                        observer.onNext(image)
                    } else if let url = URL(string: imageURL) {
                        KingfisherManager.shared.retrieveImage(with: url, options: [.downloader(self.imageDownloader)]) { downloadResult in
                            switch downloadResult {
                            case .success(let downloaded):
                                print()
                                print("=====")
                                print("cacheType: \(downloaded.cacheType)")
                                print("mock downloaded!!: \(downloaded.image)")
                                print("=====")
                                print()
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
