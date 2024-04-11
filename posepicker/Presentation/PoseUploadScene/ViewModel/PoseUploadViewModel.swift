//
//  MyPoseViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift
import RxRelay

final class PoseUploadViewModel {
    weak var coordinator: PoseUploadCoordinator?
    
    init(coordinator: PoseUploadCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let pageviewTransitionDelegateEvent: Observable<Void>
        let currentPage: Observable<Int>
    }
    
    struct Output {
        let pageTransitionEvent = PublishRelay<Int>()
        let selectedSegmentIndex = BehaviorRelay<Int>(value: 0)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.pageviewTransitionDelegateEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else {return}
                coordinator.selectPage(coordinator.currentPage() ?? .headcount)
                output.pageTransitionEvent.accept(coordinator.currentPage()?.pageOrderNumber() ?? 0)
            })
            .disposed(by: disposeBag)
        
        input.currentPage
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else { return }
                coordinator.setSelectedIndex($0)
            })
            .disposed(by: disposeBag)
        
        if let coordinator = self.coordinator {
            coordinator.currentIndexFromView
                .subscribe(onNext: {
                    output.selectedSegmentIndex.accept($0)
                })
                .disposed(by: disposeBag)
        }
        
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
