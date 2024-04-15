//
//  ReportViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/12/24.
//

import Foundation
import RxSwift

final class ReportViewModel {
    weak var coordinator: PoseFeedCoordinator?
    
    init(coordinator: PoseFeedCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        return output
    }
}
