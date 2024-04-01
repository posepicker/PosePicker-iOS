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
    private let posepickRepository: PosePickRepository
    private let disposeBag = DisposeBag()
    
    var poseImage = PublishSubject<UIImage>()
    
    init(posepickRepository: PosePickRepository) {
        self.posepickRepository = posepickRepository
    }
    
    // 캐시 데이터 정제 로직도 레파지토리에 있어야됨
    func fetchPosePick(peopleCount: Int) {
        posepickRepository
            .fetchPoseImage(peopleCount: peopleCount)
            .subscribe(onNext: { [weak self] in
                self?.poseImage.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
