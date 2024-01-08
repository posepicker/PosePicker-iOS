//
//  BookmarkFeedCellViewModel.swift
//  posepicker
//
//  Created by 박경준 on 12/5/23.
//

import UIKit

import RxCocoa
import RxSwift

class BookmarkFeedCellViewModel {
    let image = BehaviorRelay<UIImage?>(value: nil)
    let poseId = BehaviorRelay<Int>(value: -1)
    let bookmarkCheck = BehaviorRelay<Bool>(value: false)
    
    init(image: UIImage?, poseId: Int, bookmarkCheck: Bool) {
        self.image.accept(image)
        self.poseId.accept(poseId)
        self.bookmarkCheck.accept(bookmarkCheck)
    }
}
