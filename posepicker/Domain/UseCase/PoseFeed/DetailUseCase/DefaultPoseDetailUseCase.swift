//
//  DefaultPoseDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import UIKit
import RxSwift
import RxRelay
import Kingfisher

final class DefaultPoseDetailUseCase: PoseDetailUseCase {
    
    private var disposeBag = DisposeBag()
    private let poseDetailRepository: PoseDetailRepository
    private let poseId: Int
    
    init(poseDetailRepository: PoseDetailRepository, poseId: Int) {
        self.poseDetailRepository = poseDetailRepository
        self.poseId = poseId
    }

    var image = BehaviorRelay<UIImage?>(value: nil)
    var tagItems = BehaviorRelay<[String]>(value: [])
    var sourceUrl = BehaviorRelay<String>(value: "")
    var source = BehaviorRelay<String>(value: "")
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    private let imageURL = BehaviorRelay<String>(value: "")
    
    func getPoseInfo() {
        self.poseDetailRepository
            .fetchPoseInfo(poseId: self.poseId)
            .subscribe(onNext: { [weak self] pose in
                let tagAttributes = pose.poseInfo.tagAttributes ?? ""
                self?.tagItems.accept(tagAttributes.split(separator: ",").map { String($0) })
                self?.imageURL.accept(pose.poseInfo.imageKey)
                
                let sourceURL = pose.poseInfo.sourceUrl ?? ""
                
                if String(sourceURL.prefix(5)) == "https" {
                    self?.sourceUrl.accept(sourceURL)
                } else {
                    self?.sourceUrl.accept("https://" + sourceURL)
                }
                
                let source = pose.poseInfo.source ?? ""
                self?.source.accept(source)
            })
            .disposed(by: self.disposeBag)
        
        imageURL
            .withUnretained(self)
            .flatMapLatest { (owner, url) in
                owner.cacheItem(for: url)
            }
            .map { $0?.resize(newWidth: UIScreen.main.bounds.width )}
            .bind(to: image)
            .disposed(by: disposeBag)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        self.poseDetailRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func cacheItem(for imageURL: String?) -> Observable<UIImage?> {
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
}
