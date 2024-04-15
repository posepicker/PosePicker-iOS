//
//  PosePickUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import UIKit
import RxSwift

protocol PosePickUseCase {
    var poseImage: PublishSubject<UIImage?> { get set }
    func fetchPosePick(peopleCount: Int)
}

extension PosePickUseCase {
    // 이미지 재요청시 기존 이미지 삭제
    func setImageNil() {
        poseImage.onNext(nil)
    }
}
