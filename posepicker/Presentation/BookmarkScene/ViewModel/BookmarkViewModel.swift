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
        let bookmarkButtonTapEvent: Observable<(Int, Bool)>
    }
    
    struct Output {
        let bookmarkContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        let bookmarkContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let isLoading = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output{
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
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
        
        input.bookmarkCellTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentBookmarkDetail(viewModel: $0)
            })
            .disposed(by: disposeBag)
        
        // 북마크 탭 이후 포즈피드 데이터 바인딩
        input.bookmarkButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.bookmarkUseCase.bookmarkContent(poseId: $0.0, currentChecked: $0.1)
                guard let coordinator = self?.coordinator else { return }
                coordinator.bookmarkBindingDelegate?.coordinatorBookmarkModified(childCoordinator: coordinator, poseId: $0.0)
            })
            .disposed(by: disposeBag)
        
        self.bookmarkUseCase
            .contentLoaded
            .subscribe(onNext: {
                output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
