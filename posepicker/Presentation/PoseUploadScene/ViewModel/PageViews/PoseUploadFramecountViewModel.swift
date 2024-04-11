//
//  PoseUploadFramecountViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift

final class PoseUploadFramecountViewModel {
    weak var coordinator: PoseUploadCoordinator?
    
    init(coordinator: PoseUploadCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let nextButtonTapEvent: Observable<Void>
        let expandButtonTapEvent: Observable<(CGPoint, UIImage?)>
        let selectedFrameCount: Observable<String>
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
        
        input.expandButtonTapEvent
            .subscribe(onNext: { [weak self] (origin, image) in
                self?.coordinator?.presentImageExpand(origin: origin, image: image)
            })
            .disposed(by: disposeBag)
        
        input.selectedFrameCount
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.framecount.accept($0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
