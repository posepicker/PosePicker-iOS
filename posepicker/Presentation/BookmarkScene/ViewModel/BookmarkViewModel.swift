//
//  BookmarkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class BookmarkViewModel {
    weak var coordinator: BookmarkCoordinator?
    private let bookmarkUseCase: BookmarkUseCase
    
    init(coordinator: BookmarkCoordinator?, bookmarkUseCase: BookmarkUseCase) {
        self.coordinator = coordinator
        self.bookmarkUseCase = bookmarkUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let bookmarkCellTapEvent: Observable<BookmarkFeedCellViewModel>
    }
    
    struct Output {
        let bookmarkContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        let bookmarkContentSizes = BehaviorRelay<[CGSize]>(value: [])
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output{
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.bookmarkUseCase.fetchFeedContents(pageNumber: 0, pageSize: 8)
            })
            .disposed(by: disposeBag)
        
        self.bookmarkUseCase
            .bookmarkContents
            .subscribe(onNext: {
                output.bookmarkContents.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.bookmarkUseCase
            .contentSizes
            .subscribe(onNext: {
                output.bookmarkContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
