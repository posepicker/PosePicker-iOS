//
//  PosePickUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import UIKit
import RxSwift

protocol PosePickUseCase {
    var poseImage: PublishSubject<UIImage> { get set }
    func fetchPosePick(peopleCount: Int)
}
