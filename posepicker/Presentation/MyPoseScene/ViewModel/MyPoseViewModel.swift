//
//  MyPoseViewModel.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift
import RxRelay

final class MyPoseViewModel {
    weak var coordinator: MyPoseCoordinator?
    private let myPoseUseCase: MyPoseUseCase
    
    init(coordinator: MyPoseCoordinator?, myPoseUseCase: MyPoseUseCase) {
        self.coordinator = coordinator
        self.myPoseUseCase = myPoseUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let pageviewTransitionDelegateEvent: Observable<Void>
        let currentPageViewIndex: Observable<Int>
        let refreshCountEvent: Observable<Void>
    }
    
    struct Output {
        let uploadedCount = BehaviorRelay<String>(value: "등록 0")
        let savedCount = BehaviorRelay<String>(value: "저장 0")
        let pageTransitionEvent = PublishRelay<Int>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.pageviewTransitionDelegateEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else {return}
                output.pageTransitionEvent.accept(coordinator.currentPage()?.pageOrderNumber() ?? 0)
            })
            .disposed(by: disposeBag)
        
        input.currentPageViewIndex
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else { return }
                coordinator.setSelectedIndex($0)
            })
            .disposed(by: disposeBag)
        
        input
            .viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.myPoseUseCase.fetchPoseCount()
            })
            .disposed(by: disposeBag)
        
        myPoseUseCase
            .uploadedPoseCount
            .subscribe(onNext: {
                output.uploadedCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        myPoseUseCase
            .savedPoseCount
            .subscribe(onNext: {
                output.savedCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.refreshCountEvent
            .subscribe(onNext: { [weak self] in
                self?.myPoseUseCase.fetchPoseCount()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    /// UIPageViewController DataSource - viewControllerBefore
    func viewControllerBefore() -> UIViewController? {
        return self.coordinator?.viewControllerBefore()
    }
    
    /// UIPageViewController DataSource -> viewControllerAfter
    func viewControllerAfter() -> UIViewController? {
        return self.coordinator?.viewControllerAfter()
    }
}
