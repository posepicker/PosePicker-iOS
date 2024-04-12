//
//  PoseUploadTagViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class PoseUploadTagViewModel {
    weak var coordinator: PoseUploadCoordinator?
    
    init(coordinator: PoseUploadCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let nextButtonTapEvent: Observable<Void>
        let expandButtonTapEvent: Observable<(CGPoint, UIImage?)>
        let inputCompleted: Observable<Bool>
        let selectedTags: Observable<[String]>
    }
    
    struct Output {
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.nextButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.setSelectedIndex(3)
            })
            .disposed(by: disposeBag)
        
        input.expandButtonTapEvent
            .subscribe(onNext: { [weak self] (origin, image) in
                self?.coordinator?.presentImageExpand(origin: origin, image: image)
            })
            .disposed(by: disposeBag)
        
        input.inputCompleted
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.refreshDataSource()
                self?.coordinator?.inputCompleted.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.selectedTags
            .map { tagArray in
                var string = ""
                tagArray.forEach { string += "\($0)," }
                return string
            }
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.tags.accept($0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

