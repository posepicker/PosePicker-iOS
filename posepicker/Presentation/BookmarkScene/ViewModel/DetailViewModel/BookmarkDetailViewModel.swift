//
//  BookmarkDetailViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/9/24.
//

import Foundation
import RxRelay
import RxSwift

final class BookmarkDetailViewModel {
    weak var coordinator: BookmarkCoordinator?
    private let bookmarkUseCase: BookmarkUseCase
    
    init(coordinator: BookmarkCoordinator, bookmarkUseCase: BookmarkUseCase) {
        self.coordinator = coordinator
        self.bookmarkUseCase = bookmarkUseCase
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
