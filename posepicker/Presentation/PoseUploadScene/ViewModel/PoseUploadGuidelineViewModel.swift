//
//  MyPoseGuidelineViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit
import RxSwift

final class MyPoseGuidelineViewModel {
    weak var coordinator: PoseUploadCoordinator?
    
    init(coordinator: PoseUploadCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let guidelineCheckButtonTapEvent: Observable<Void>
        let imageLoadCompletedEvent: Observable<UIImage?>
        let imageLoadFailedEvent: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.guidelineCheckButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushGuideline()
            })
            .disposed(by: disposeBag)
        
        input.imageLoadCompletedEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushPoseUploadView(image: $0)
            })
            .disposed(by: disposeBag)
        
        input.imageLoadFailedEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentImageLoadFailedPopup()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
