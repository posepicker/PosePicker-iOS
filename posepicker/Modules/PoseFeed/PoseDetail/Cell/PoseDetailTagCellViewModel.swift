//
//  PoseDetailTagCellViewModel.swift
//  posepicker
//
//  Created by Jun on 2023/11/18.
//

import Foundation
import RxCocoa

class PoseDetailTagCellViewModel {
    let title = BehaviorRelay<String>(value: "")
    
    init(title: String) {
        self.title.accept(title)
    }
}
