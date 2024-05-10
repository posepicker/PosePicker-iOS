//
//  MyPoseUploadedViewModel.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class MyPoseUploadedViewModel {
    weak var coordinator: MyPoseCoordinator?
    private let myPoseUseCase: MyPoseUseCase
    
    init(coordinator: MyPoseCoordinator?, myPoseUseCase: MyPoseUseCase) {
        self.coordinator = coordinator
        self.myPoseUseCase = myPoseUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let bookmarkCellTapEvent: Observable<BookmarkFeedCellViewModel>
        let bookmarkButtonTapEvent: Observable<(Int, Bool)>
        let infiniteScrollEvent: Observable<Void>
        let contentsUpdateEvent: Observable<Void> // 외부에서 북마크 탭하여 컨텐츠 업데이트
    }
    
    struct Output {
        let uploadedContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
        let uploadedContentSizes = BehaviorRelay<[CGSize]>(value: [])
        let isLoading = BehaviorRelay<Bool>(value: false)
        let isLastPage = BehaviorRelay<Bool>(value: true)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output{
        let output = Output()
        
        let currentPage = BehaviorRelay<Int>(value: 0)
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                self?.myPoseUseCase.fetchFeedContents(pageNumber: 0, pageSize: 8)
            })
            .disposed(by: disposeBag)
        
        self.myPoseUseCase
            .uploadedContents
            .subscribe(onNext: {
                output.uploadedContents.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.myPoseUseCase
            .contentSizes
            .subscribe(onNext: {
                output.uploadedContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.bookmarkCellTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentBookmarkDetail(viewModel: $0)
            })
            .disposed(by: disposeBag)
        
        // 북마크 탭 이후 포즈피드 데이터 바인딩
//        input.bookmarkButtonTapEvent
//            .subscribe(onNext: { [weak self] in
//                self?.myPoseUseCase.bookmarkContent(poseId: $0.0, currentChecked: $0.1)
//                guard let coordinator = self?.coordinator else { return }
//                coordinator.bookmarkBindingDelegate?.coordinatorBookmarkModified(childCoordinator: coordinator, poseId: $0.0)
//            })
//            .disposed(by: disposeBag)
        
        /// 무한스크롤 트리거 로직
        input.infiniteScrollEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                let nextPage = currentPage.value + 1
                currentPage.accept(nextPage)
                
                self?.myPoseUseCase.fetchFeedContents(
                    pageNumber: nextPage,
                    pageSize: 8
                )
            })
            .disposed(by: disposeBag)
        
        self.myPoseUseCase
            .contentLoaded
            .subscribe(onNext: {
                output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        self.myPoseUseCase
            .isLastPage
            .subscribe(onNext: {
                output.isLastPage.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.contentsUpdateEvent
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                currentPage.accept(0)
                self?.myPoseUseCase.fetchFeedContents(pageNumber: 0, pageSize: 8)
            })
            .disposed(by: disposeBag)

        return output
    }
}
