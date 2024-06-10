//
//  MockMyPageCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import UIKit
import RxSwift

@testable import posepicker

final class MockMyPageCoordinator: MyPageCoordinator {
    var loginDelegate: CoordinatorLoginDelegate?
    
    private let pageviewCoordinator = MockPageViewCoordinator(
        UINavigationController(
            rootViewController: UIViewController()
        )
    )
    
    private var loginValue: LoginPopUpView.SocialLogin = .apple
    
    func pushWebView(webView: WebViewList) {
        
    }
    
    func presentLogoutPopup(disposeBag: DisposeBag) -> Observable<LoginPopUpView.SocialLogin?> {
        switch loginValue {
        case .apple:
            self.loginValue = .kakao
        case .kakao:
            self.loginValue = .none
        case .none:
            self.loginValue = .apple
        }
        return .just(self.loginValue)
    }
    
    func pushRevokeQuestionView(commonUseCase: CommonUseCase) {
        
    }
    
    func presentRevokeConfirmPopup(disposeBag: RxSwift.DisposeBag) -> Observable<posepicker.LoginPopUpView.SocialLogin?> {
        switch loginValue {
        case .apple:
            self.loginValue = .kakao
        case .kakao:
            self.loginValue = .none
        case .none:
            self.loginValue = .apple
        }
        return .just(self.loginValue)
    }
    
    func popRevokeView() {
        
    }
    
    var finishDelegate: (any posepicker.CoordinatorFinishDelegate)?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    var type: CoordinatorType = .mypose
    
    func start() {
        
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.loginDelegate = self.pageviewCoordinator
    }
    
    
}
