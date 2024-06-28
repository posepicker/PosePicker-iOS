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
    let poseId = BehaviorRelay<Int>(value: -1)
    let bookmarkCheck = BehaviorRelay<Bool>(value: false)
    let size = BehaviorRelay<CGSize>(value: .init(width: 0, height: 0))
    let imageURL = BehaviorRelay<String>(value: "")
    
    init(poseId: Int, bookmarkCheck: Bool, size: CGSize, imageURL: String) {
        self.poseId.accept(poseId)
        self.bookmarkCheck.accept(bookmarkCheck)
        self.size.accept(size)
        self.imageURL.accept(imageURL)
    }
}
