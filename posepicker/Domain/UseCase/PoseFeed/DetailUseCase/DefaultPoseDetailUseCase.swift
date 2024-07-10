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
    var contentLoaded = PublishSubject<Void>()
    
    private let imageURL = BehaviorRelay<String>(value: "")
    
    func getPoseInfo() {
        self.poseDetailRepository
            .fetchPoseInfo(poseId: self.poseId)
            .subscribe(onNext: { [weak self] pose in
                guard let self = self else { return }
                var tags = self.tagItems.value
                if let peopleCountTag = PeopleCountTags.getTagTitleFromIndex(index: pose.poseInfo.peopleCount ?? 0),
                   peopleCountTag != "전체" {
                    tags += [peopleCountTag]
                }
                
                if let frameCountTag = FrameCountTags.getTagTitleFromNumberOfFrameCount(number: pose.poseInfo.frameCount ?? 0),
                   frameCountTag != "전체" {
                    tags += [frameCountTag]
                }
                
                let tagAttributes = pose.poseInfo.tagAttributes ?? ""
                tags += tagAttributes.split(separator: ",").map { String($0) }
                
                self.tagItems.accept(tags)
                
                self.imageURL.accept(pose.poseInfo.imageKey)
                
                if let sourceURL = pose.poseInfo.sourceUrl {
                    self.sourceUrl.accept(sourceURL)
                    
                    if String(sourceURL.prefix(5)) == "https" {
                        self.sourceUrl.accept(sourceURL)
                    } else {
                        self.sourceUrl.accept("https://" + sourceURL)
                    }
                }
                
                if let source = pose.poseInfo.source {
                    self.source.accept(source)
                }
            })
            .disposed(by: self.disposeBag)
        
        imageURL
            .withUnretained(self)
            .flatMapLatest { (owner, url) in
                owner.poseDetailRepository.cacheItem(for: url)
            }
            .map { $0?.resize(newWidth: UIScreen.main.bounds.width )}
            .subscribe(onNext: { [weak self] in
                self?.contentLoaded.onNext(())
                self?.image.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        self.poseDetailRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
