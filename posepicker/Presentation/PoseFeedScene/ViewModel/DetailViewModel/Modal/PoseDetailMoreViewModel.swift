//
//  PoseDetailMoreViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/12/24.
//

import Foundation
import RxSwift

final class PoseDetailMoreViewModel {
    weak var coordinator: PoseFeedCoordinator?
    
    init(coordinator: PoseFeedCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let closeButtonTapEvent: Observable<Void>
        let reportButtonTapEvent: Observable<Int>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.closeButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.dismissShowMoreModal()
            })
            .disposed(by: disposeBag)
        
        input.reportButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentReportView(poseId: $0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
