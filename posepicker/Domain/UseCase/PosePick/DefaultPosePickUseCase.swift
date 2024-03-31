//
//  DefaultPosePickUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import UIKit
import RxSwift
import Kingfisher

final class DefaultPosePickUseCase: PosePickUseCase {
    private let posepickRepository: DefaultPosePickRepository
    private let disposeBag = DisposeBag()
    
    var poseImage = PublishSubject<UIImage>()
    
    init(posepickRepository: DefaultPosePickRepository) {
        self.posepickRepository = posepickRepository
    }
    
    func fetchPosePick(peopleCount: Int) {
        posepickRepository
            .fetchPose(peopleCount: peopleCount)
            .map { $0.poseInfo.imageKey }
            .withUnretained(self)
            .flatMapLatest { (owner, imageURL) -> Observable<UIImage> in
                return owner.cacheItem(for: imageURL)
            }
            .catchAndReturn(ImageLiteral.imgHelp24)
            .subscribe(onNext: { [weak self] in
                self?.poseImage.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func cacheItem(for imageURL: String) -> Observable<UIImage> {
        return Observable.create { observer in
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
            return Disposables.create {
                
            }
            
        }
    }
}
