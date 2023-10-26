//
//  PoseTalkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class PoseTalkViewModel {
    struct Input {
        let poseTalkButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let animate: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(animate: input.poseTalkButtonTapped.asDriver())
    }
}
