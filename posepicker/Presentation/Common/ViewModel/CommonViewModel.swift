//
//  CommonViewModel.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

import RxRelay
import RxSwift

final class CommonViewModel {
    private weak var coordinator: PageViewCoordinator?
    private let commonUseCase: CommonUseCase
    
    struct Input {
        let pageviewTransitionDelegateEvent: Observable<Void>
        let myPageButtonTapped: Observable<Void>
        let currentPage: Observable<Int>
    }
    
    struct Output {
        let pageTransitionEvent = PublishRelay<Int>()
    }
    
    init(coordinator: PageViewCoordinator?, commonUseCase: CommonUseCase) {
        self.coordinator = coordinator
        self.commonUseCase = commonUseCase
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.pageviewTransitionDelegateEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else {return}
                coordinator.selectPage(coordinator.currentPage() ?? .posepick)
                output.pageTransitionEvent.accept(coordinator.currentPage()?.pageOrderNumber() ?? 0)
            })
            .disposed(by: disposeBag)
        
        input.myPageButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else { return }
                coordinator.pushMyPage()
            })
            .disposed(by: disposeBag)
        
        input.currentPage
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else { return }
                coordinator.setSelectedIndex($0)
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
