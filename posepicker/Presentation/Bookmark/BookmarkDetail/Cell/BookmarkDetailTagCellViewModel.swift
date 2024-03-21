//
//  BookmarkDetailTagCellViewModel.swift
//  posepicker
//
//  Created by 박경준 on 12/13/23.
//

import Foundation
import RxCocoa

class BookmarkDetailTagCellViewModel {
    let title = BehaviorRelay<String>(value: "")
    
    init(title: String) {
        self.title.accept(title)
    }
}
