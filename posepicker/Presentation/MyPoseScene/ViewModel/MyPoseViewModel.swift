//
//  MyPoseViewModel.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation

final class MyPoseViewModel {
    weak var coordinator: MyPoseCoordinator?
    private let myPoseUseCase: MyPoseUseCase
    
    init(coordinator: MyPoseCoordinator?, myPoseUseCase: MyPoseUseCase) {
        self.coordinator = coordinator
        self.myPoseUseCase = myPoseUseCase
    }
}
