//
//  PoseFeedFilterViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import Foundation
import RxSwift
import RxRelay

final class PoseFeedFilterViewModel {
    weak var coordinator: PoseFeedCoordinator?
    private var posefeedFilterUseCase: PoseFeedFilterUseCase
    
    init(coordinator: PoseFeedCoordinator?, posefeedFilterUseCase: PoseFeedFilterUseCase) {
        self.coordinator = coordinator
        self.posefeedFilterUseCase = posefeedFilterUseCase
    }
    
    struct Input {
        
    }
    
    struct Output {
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        self.posefeedFilterUseCase.tagItems
            .subscribe(onNext: {
                output.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
