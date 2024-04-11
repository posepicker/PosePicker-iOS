//
//  PoseUploadFramecountViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import Foundation
import RxSwift

final class PoseUploadFramecountViewModel {
    weak var coordinator: PoseUploadCoordinator?
    
    init(coordinator: PoseUploadCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let nextButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.nextButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.setSelectedIndex(2)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
