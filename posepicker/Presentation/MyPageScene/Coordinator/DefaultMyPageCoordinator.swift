//
//  DefaultMyPageCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultMyPageCoordinator: MyPageCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    weak var loginDelegate: CoordinatorLoginDelegate?
    
    var navigationController: UINavigationController
    var myPageViewController: MyPageViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypage
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.myPageViewController = MyPageViewController()
    }
    
    func start() {
        self.myPageViewController.viewModel = MyPageViewModel(
            coordinator: self,
            myPageUseCase: DefaultMyPageUseCase(),
            commonUseCase: DefaultCommonUseCase(
                userRepository: DefaultUserRepository(
                    networkService: DefaultNetworkService(),
                    keychainService: DefaultKeychainService()
                )
            )
        )
        self.navigationController.pushViewController(myPageViewController, animated: true)
    }
    
    func pushWebView(webView: WebViewList) {
        var mypageWebviewVC: MypageWebViewController!
        
        switch webView {
        case .notice:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "공지사항"
            )
            
        case .faq:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "자주 묻는 질문"
            )
        case .sns:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "포즈피드 공식 SNS"
            )
        case .serviceInquiry:
            if let url = URL(string: "https://litt.ly/posepicker") {
                UIApplication.shared.open(url)
            }
            return
        case .serviceInformation:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "이용약관"
            )
        case .privacyInformation:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "개인정보 처리방침"
            )
        }
        
        self.navigationController.pushViewController(mypageWebviewVC, animated: true)
    }
    
    func presentLogoutPopup(disposeBag: DisposeBag) -> Observable<LoginPopUpView.SocialLogin?> {
        let logoutConfirmed = BehaviorRelay<LoginPopUpView.SocialLogin?>(value: nil)
        
        let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: true, isLabelNeeded: true)
        popupViewController.modalTransitionStyle = .crossDissolve
        popupViewController.modalPresentationStyle = .overFullScreen
        let popupView = popupViewController.popUpView as! PopUpView
        popupView.alertMainLabel.text = "로그아웃"
        popupView.alertText.accept("북마크는 로그인 시에만 유지되어요.\n정말 로그아웃하시겠어요?")
        popupView.confirmButton.setTitle("로그인 유지", for: .normal)
        popupView.cancelButton.setTitle("로그아웃", for: .normal)

        popupView.confirmButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        // 현재 로그인된 계정이 카카오인지 모름
        // 토큰 삭제는 뷰모델에서 이루어짐
        popupView.cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                if let socialLogin = UserDefaults.standard.string(forKey: K.SocialLogin.socialLogin),
                   socialLogin == K.SocialLogin.kakao {
                    logoutConfirmed.accept(.kakao)
                } else {
                    logoutConfirmed.accept(.apple)
                }
                self.loginDelegate?.coordinatorLoginCompleted(childCoordinator: self)
            })
            .disposed(by: disposeBag)

        self.navigationController.present(popupViewController, animated: true)
        return logoutConfirmed.asObservable()
    }
    
    func pushRevokeQuestionView(commonUseCase: CommonUseCase) {
        let revokeVC = UserRevokeViewController()
        revokeVC.viewModel = UserRevokeViewModel(
            coordinator: self,
            commonUseCase: commonUseCase
        )
        self.navigationController.pushViewController(revokeVC, animated: true)
    }
    
    func presentRevokeConfirmPopup(disposeBag: DisposeBag) -> Observable<LoginPopUpView.SocialLogin?> {
        let revokeConfirmed = BehaviorRelay<LoginPopUpView.SocialLogin?>(value: nil)
        
        let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: true, isLabelNeeded: true, isSignout: true)
        popupViewController.modalTransitionStyle = .crossDissolve
        popupViewController.modalPresentationStyle = .overFullScreen
        let popupView = popupViewController.popUpView as! PopUpView
        popupView.alertMainLabel.text = "서비스 탈퇴"
        popupView.alertText.accept("탈퇴시 올려주신 포즈는\n자동으로 삭제되지 않습니다.\n정말 탈퇴하시겠어요?")
        popupView.confirmButton.setTitle("탈퇴", for: .normal)
        popupView.cancelButton.setTitle("취소", for: .normal)

        popupView.confirmButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                if let socialLogin = UserDefaults.standard.string(forKey: K.SocialLogin.socialLogin),
                   socialLogin == K.SocialLogin.kakao {
                    revokeConfirmed.accept(.kakao)
                } else {
                    revokeConfirmed.accept(.apple)
                }
                self.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        popupView.cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        self.navigationController.present(popupViewController, animated: true)
        
        return revokeConfirmed.asObservable()
    }
    
    func popRevokeView() {
        self.navigationController.popViewController(animated: true)
    }
}
