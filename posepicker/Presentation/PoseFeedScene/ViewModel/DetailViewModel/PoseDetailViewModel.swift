//
//  PoseDetailViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import UIKit
import RxSwift
import RxRelay

final class PoseDetailViewModel {
    weak var coordinator: PoseFeedCoordinator?
//    private var posefeedUseCase: PoseFeedUseCase
    private let bindViewModel: PoseFeedPhotoCellViewModel
    
    init(coordinator: PoseFeedCoordinator?, bindViewModel: PoseFeedPhotoCellViewModel) {
        self.coordinator = coordinator
        self.bindViewModel = bindViewModel
    }
    
    struct Input {
        
    }
    
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        output.image.accept(
            bindViewModel.image.value?.resize(newWidth: UIScreen.main.bounds.width)
        )
        
        return output
    }
}
