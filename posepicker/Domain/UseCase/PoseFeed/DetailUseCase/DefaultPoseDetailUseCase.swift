//
//  DefaultPoseDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultPoseDetailUseCase: PoseDetailUseCase {
    
    private var disposeBag = DisposeBag()
    private let poseDetailRepository: PoseDetailRepository
    private let poseId: Int
    
    init(poseDetailRepository: PoseDetailRepository, poseId: Int) {
        self.poseDetailRepository = poseDetailRepository
        self.poseId = poseId
    }
    
    var tagItems = BehaviorRelay<[String]>(value: [])
    var sourceUrl = BehaviorRelay<String>(value: "")
    var pose = PublishSubject<Pose>()
    var source = BehaviorRelay<String>(value: "")
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func getPoseInfo() {
        self.poseDetailRepository
            .fetchPoseInfo(poseId: self.poseId)
            .subscribe(onNext: { [weak self] pose in
                let tagAttributes = pose.poseInfo.tagAttributes ?? ""
                self?.tagItems.accept(tagAttributes.split(separator: ",").map { String($0) })
                
                var sourceURL = pose.poseInfo.sourceUrl ?? ""
                
                if String(sourceURL.prefix(5)) == "https" {
                    self?.sourceUrl.accept(sourceURL)
                } else {
                    self?.sourceUrl.accept("https://" + sourceURL)
                }
                
                let source = pose.poseInfo.source ?? ""
                self?.source.accept(source)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        self.poseDetailRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
