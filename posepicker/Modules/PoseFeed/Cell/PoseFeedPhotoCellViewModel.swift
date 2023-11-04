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
    let imageUrl = BehaviorRelay<String>(value: "")
    
    init(imageUrl: String) {
        self.imageUrl.accept(imageUrl)
    }
}
