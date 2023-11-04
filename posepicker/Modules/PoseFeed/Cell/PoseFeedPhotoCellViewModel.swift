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
    
    init(image: UIImage?) {
        self.image.accept(image)
    }
}
