//
//  PopUpViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/16.
//

import UIKit
import AuthenticationServices
import RxCocoa
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import RxKakaoSDKUser

class PopUpViewController: BaseViewController {

    // MARK: - Subviews
    lazy var popUpView = self.isLoginPopUp ? LoginPopUpView() : PopUpView(isChoice: self.isChoice, isLabelNeeded: isLabelNeeded, isSignout: isSignout)
    
    // MARK: - Properties
    var isLoginPopUp: Bool
    var isChoice: Bool
    var isLabelNeeded: Bool
    var isSignout: Bool
    /// Optional 타입이 아니면 초기에 next로 값이 방출되어버림
//    let appleIdentityToken = BehaviorRelay<String?>(value: nil)
//    let kakaoId = BehaviorRelay<Int64?>(value: nil)
//    let email = BehaviorRelay<String?>(value: nil)
    
    /// 인사 텍스트
    private let greetText = "포즈피커 회원님 반가워요!"

    // MARK: - Initialization
    init(isLoginPopUp: Bool, isChoice: Bool, isLabelNeeded: Bool = false, isSignout: Bool = false) {
        self.isLoginPopUp = isLoginPopUp
        self.isChoice = isChoice
        self.isLabelNeeded = isLabelNeeded
        self.isSignout = isSignout
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true)
    }
    
    override func render() {
        self.view.addSubViews([popUpView])
        
        if let popUpView = popUpView as? PopUpView {
            popUpView.snp.makeConstraints { make in
                make.width.equalTo(300)
                make.height.equalTo(self.isLabelNeeded ? 228 : 158)
                make.center.equalToSuperview()
            }
        } else {
            popUpView.snp.makeConstraints { make in
                make.width.equalTo(300)
                make.height.equalTo(282)
                make.center.equalToSuperview()
            }
        }
    
    }
    
    override func configUI() {
        view.backgroundColor = .init(hex: "#000000", alpha: 0.3)
        
        /// 팝업 뷰일때
        if let popUpView = popUpView as? PopUpView {
            popUpView.completeButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.dismiss(animated: true)
                })
                .disposed(by: disposeBag)
        }
        
        /// 로그인 팝업일때
        if let popUpView = popUpView as? LoginPopUpView {
            popUpView.kakaoLoginButton.rx.tap.asDriver()
                .drive(onNext: {
                    UserDefaults.standard.setValue(K.SocialLogin.kakao, forKey: K.SocialLogin.socialLogin)
                    popUpView.socialLogin.onNext(.kakao)
                    popUpView.isLoading.accept(true)
                })
                .disposed(by: disposeBag)
            // 애플로그인
            popUpView.appleLoginButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    UserDefaults.standard.setValue(K.SocialLogin.apple, forKey: K.SocialLogin.socialLogin)
                    self?.handleAppleLogin()
                    popUpView.isLoading.accept(true)
                })
                .disposed(by: disposeBag)
        }
        
        // 팝업 내부 텍스트 높이값에 따라 흰 배경 박스 높이 동적 조정
        if let popupView =  popUpView as? PopUpView,
           !self.isLabelNeeded {
            
            popUpView.snp.updateConstraints { make in
                make.height.equalTo(134 + popupView.alertText.value.height(withConstrainedWidth: 300, font: .pretendard(.regular, ofSize: 16)))
            }
        }
    }
    
    
    func handleAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension PopUpViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData = appleIDCredential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8) else { return }
            try? KeychainManager.shared.saveItem(tokenString, itemClass: .password, key: K.Parameters.idToken)
            try? KeychainManager.shared.updateItem(with: tokenString, ofClass: .password, key: K.Parameters.idToken)
            guard let popUpView = self.popUpView as? LoginPopUpView else { return }
            popUpView.socialLogin.onNext(.apple)
            
//            self.appleIdentityToken.accept(tokenString)
        case let passwordCredential as ASPasswordCredential:
            print(passwordCredential)
            // Sign in using an existing iCloud Keychain credential.
            print("password credential .. ")
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let popUpView = popUpView as? LoginPopUpView {
            popUpView.isLoading.accept(false)
            popUpView.appleLoginButton.titleLabel?.isHidden = false
            popUpView.appleLoginButton.configuration?.image = ImageLiteral.imgAppleLogo.withRenderingMode(.alwaysOriginal)
        }
    }
}

extension PopUpViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
