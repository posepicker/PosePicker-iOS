//
//  PoseFeedPhotoCellViewModel.swift
//  posepicker
//
//  Created by Jun on 2023/11/05.
//

import UIKit

import RxCocoa
import RxSwift

class PoseFeedPhotoCellViewModel {
    let image = BehaviorRelay<UIImage?>(value: nil)
    let poseId = BehaviorRelay<Int>(value: -1)
    
    init(image: UIImage?, poseId: Int) {
        self.image.accept(image)
        self.poseId.accept(poseId)
    }
}
