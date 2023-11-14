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
    let imageKey = BehaviorRelay<String>(value: "")
    
    init(image: UIImage?, imageKey: String) {
        self.image.accept(image)
        self.imageKey.accept(imageKey)
    }
}
