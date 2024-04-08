//
//  BookmarkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation

final class BookmarkViewModel {
    weak var coordinator: BookmarkCoordinator?
    private let bookmarkUseCase: BookmarkUseCase
    
    init(coordinator: BookmarkCoordinator?, bookmarkUseCase: BookmarkUseCase) {
        self.coordinator = coordinator
        self.bookmarkUseCase = bookmarkUseCase
    }
}
