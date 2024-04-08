//
//  MyPageViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation

final class MyPageViewModel {
    weak var coordinator: MyPageCoordinator?
    private let myPageUseCase: MyPageUseCase
    
    init(coordinator: MyPageCoordinator?, myPageUseCase: MyPageUseCase) {
        self.coordinator = coordinator
        self.myPageUseCase = myPageUseCase
    }
}
