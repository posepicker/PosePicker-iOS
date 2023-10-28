//
//  RegisteredFilterCellViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/28.
//

import Foundation
import RxCocoa
import RxSwift

class RegisteredFilterCellViewModel {
    let title = BehaviorRelay<String>(value: "")
    
    init(title: String) {
        self.title.accept(title)
    }
}
