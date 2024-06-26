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
    weak var coordinator: PageViewCoordinator?
    private let commonUseCase: CommonUseCase
    
    struct Input {
        let pageviewTransitionDelegateEvent: Observable<Void>
        let myPageButtonTapEvent: Observable<Void>
        let currentPage: Observable<Int>
        let bookmarkButtonTapEvent: Observable<Void>
        let removeMyPoseContentsEvent: Observable<Void>
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
                output.pageTransitionEvent.accept(coordinator.currentPage().pageOrderNumber())
            })
            .disposed(by: disposeBag)
        
        input.myPageButtonTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let coordinator = self.coordinator else { return }
                coordinator.pushMyPage()
            })
            .disposed(by: disposeBag)
        
        input.currentPage
            .withUnretained(self)
            .flatMap { (owner, pageIndex) -> Observable<LoginPopUpView.SocialLogin> in
                guard let coordinator = owner.coordinator else { return .empty() }
                if UserDefaults.standard.bool(forKey: K.SocialLogin.isLoggedIn) {
                    coordinator.setSelectedIndex(pageIndex)
                    return .empty()
                } else if pageIndex == 3 {
                    return coordinator.showLoginFlow()
                } else {
                    coordinator.setSelectedIndex(pageIndex)
                    return .empty()
                }
            }
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .apple:
                    self?.commonUseCase.loginWithApple()
                case .kakao:
                    self?.commonUseCase.loginWithKakao()
                case .none:
                    self?.coordinator?.setSelectedIndex(0)
                }
                output.pageTransitionEvent.accept(0)
                self?.coordinator?.setSelectedIndex(0)
            })
            .disposed(by: disposeBag)
        
        input.bookmarkButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _) -> Observable<LoginPopUpView.SocialLogin> in
                guard let coordinator = owner.coordinator else { return .empty() }
                return coordinator.pushBookmarkPage()
            }
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .apple:
                    self?.commonUseCase.loginWithApple()
                case .kakao:
                    self?.commonUseCase.loginWithKakao()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        self.commonUseCase
            .loginCompleted
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.dismissLoginPopUp()
            })
            .disposed(by: disposeBag)
            
        input.removeMyPoseContentsEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.removeMyPoseContents()
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
