//
//  MyPoseViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import Foundation
import RxSwift

final class PoseUploadViewModel {
    weak var coordinator: PoseUploadCoordinator?
//    private let bookmarkUseCase: BookmarkUseCase
    
    init(coordinator: PoseUploadCoordinator?) {
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
