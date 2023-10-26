//
//  PoseFeedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class PoseFeedViewModel {
    struct Input {
        let filterButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let presentModal: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(presentModal: input.filterButtonTapped.asDriver())
    }
}
