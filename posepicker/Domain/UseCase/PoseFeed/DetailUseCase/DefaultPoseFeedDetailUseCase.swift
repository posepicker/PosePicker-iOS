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
        
        self.poseDetailRepository
            .fetchPoseInfo(poseId: self.poseId)
            .subscribe(self.pose)
            .disposed(by: self.disposeBag)
    }
    
    var tagItems = BehaviorRelay<[String]>(value: [])
    var sourceUrl = PublishSubject<String>()
    var pose = PublishSubject<Pose>()
    var source = PublishSubject<String>()
    
    func getTagsFromPoseInfo() {
        pose
            .compactMap { $0.poseInfo.tagAttributes }
            .map { $0.split(separator: ",").map { String($0) }}
            .subscribe(onNext: { [weak self] in
                self?.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    func getSourceURLFromPoseInfo() {
        pose
            .compactMap { $0.poseInfo.sourceUrl }
            .subscribe(onNext: { [weak self] in
                self?.sourceUrl.onNext($0)
            })
            .disposed(by: self.disposeBag)
    }
    
    func getSourceFromPoseInfo() {
        pose
            .compactMap { $0.poseInfo.source }
            .subscribe(onNext: { [weak self] in
                self?.source.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
