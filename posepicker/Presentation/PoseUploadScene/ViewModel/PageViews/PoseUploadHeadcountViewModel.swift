//
//  PoseUploadHeadCountViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import Foundation
import RxSwift

final class PoseUploadHeadcountViewModel {
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
                self?.coordinator?.setSelectedIndex(1)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
