//
//  MyPageViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class MyPageViewModel {
    weak var coordinator: MyPageCoordinator?
    private let commonUseCase: CommonUseCase
    
    init(coordinator: MyPageCoordinator?, commonUseCase: CommonUseCase) {
        self.coordinator = coordinator
        self.commonUseCase = commonUseCase
    }
    
    struct Input {
        let noticeButtonTapEvent: Observable<Void>
        let faqButtonTapEvent: Observable<Void>
        let snsButtonTapEvent: Observable<Void>
        let serviceInquiryButtonTapEvent: Observable<Void>
        let serviceInformationButtonTapEvent: Observable<Void>
        let privacyInformationButtonTapEvent: Observable<Void>
        let logoutButtonTapEvent: Observable<Void>
        let signoutButtonTapEvent: Observable<Void>
        let loginButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let refreshLoginState = PublishSubject<Bool>()
        let revokeCompleted = PublishSubject<Void>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.noticeButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .notice)
            })
            .disposed(by: disposeBag)
        
        input.faqButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .faq)
            })
            .disposed(by: disposeBag)
        
        input.snsButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .sns)
            })
            .disposed(by: disposeBag)
        
        input.serviceInquiryButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .serviceInquiry)
            })
            .disposed(by: disposeBag)
        
        input.serviceInformationButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .serviceInformation)
            })
            .disposed(by: disposeBag)
        
        input.privacyInformationButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .privacyInformation)
            })
            .disposed(by: disposeBag)
        
        input.loginButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _) -> Observable<LoginPopUpView.SocialLogin> in
                guard let coordinator = owner.coordinator else { return .empty() }
                return coordinator.loginDelegate?.coordinatorLoginRequested(childCoordinator: coordinator) ?? .empty()
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
                guard let coordinator = self?.coordinator else { return }
                self?.coordinator?.loginDelegate?.coordinatorLoginCompleted(childCoordinator: coordinator)
                output.refreshLoginState.onNext(true)
            })
            .disposed(by: disposeBag)
        
        self.commonUseCase
            .logoutCompleted
            .subscribe(onNext: { [weak self] in
                guard let coordinator = self?.coordinator else { return }
                self?.coordinator?.loginDelegate?.coordinatorLoginCompleted(childCoordinator: coordinator)
                output.refreshLoginState.onNext(false)
            })
            .disposed(by: disposeBag)
        
        self.commonUseCase
            .revokeCompleted
            .subscribe(onNext: { [weak self] in
                guard let coordinator = self?.coordinator else { return }
                self?.coordinator?.loginDelegate?.coordinatorLoginCompleted(childCoordinator: coordinator)
                output.revokeCompleted.onNext(())
            })
            .disposed(by: disposeBag)
        
        input.logoutButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _ ) -> Observable<LoginPopUpView.SocialLogin?> in
                guard let coordinator = owner.coordinator else { return .empty() }
                return coordinator.presentLogoutPopup(disposeBag: disposeBag)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?.commonUseCase.logout(with: $0)
            })
            .disposed(by: disposeBag)
        
        input.signoutButtonTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.coordinator?.pushRevokeQuestionView(commonUseCase: self.commonUseCase)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
