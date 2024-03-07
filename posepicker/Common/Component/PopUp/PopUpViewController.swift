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
    let appleIdentityToken = BehaviorRelay<String?>(value: nil)
    let kakaoId = BehaviorRelay<Int64?>(value: nil)
    let email = BehaviorRelay<String?>(value: nil)

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
            /// 카카오 로그인
            /// 이메일 동의항목을 초기에 체크하기 때문에 사실상 이메일을 받지 못하는 경우는 없음
            /// 그럼에도 체크를 해제하는 유저를 고려하여 추후 에러처리가 필요할듯 함
            popUpView.kakaoLoginButton.rx.tap.asDriver()
                .drive(onNext: {[unowned self] in
                    UserDefaults.standard.setValue(K.SocialLogin.kakao, forKey: K.SocialLogin.socialLogin)
                    popUpView.socialLogin.onNext(.kakao)
                    popUpView.isLoading.accept(true)
                    if (AuthApi.hasToken()) {
                        UserApi.shared.rx.accessTokenInfo()
                            .subscribe(onSuccess: { _ in
                                UserApi.shared.rx.me()
                                    .subscribe(onSuccess: { [unowned self] in
                                        self.email.accept($0.kakaoAccount?.email)
                                        self.kakaoId.accept($0.id)
                                        popUpView.isLoading.accept(false)
                                    })
                                    .disposed(by: self.disposeBag)
                            }, onFailure: { error in
                                if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                                    if (UserApi.isKakaoTalkLoginAvailable()) {
                                        UserApi.shared.rx.loginWithKakaoTalk()
                                            .subscribe(onNext: { [unowned self] _ in
                                                UserApi.shared.rx.me()
                                                    .subscribe(onSuccess: { [unowned self] in
                                                        self.email.accept($0.kakaoAccount?.email)
                                                        self.kakaoId.accept($0.id)
                                                        popUpView.isLoading.accept(false)
                                                    })
                                                    .disposed(by: self.disposeBag)
                                            })
                                            .disposed(by: self.disposeBag)
                                    } else {
                                        UserApi.shared.rx.loginWithKakaoAccount()
                                            .subscribe(onNext: { [unowned self] _ in
                                                UserApi.shared.rx.me()
                                                    .subscribe(onSuccess: { [unowned self] in
                                                        self.email.accept($0.kakaoAccount?.email)
                                                        self.kakaoId.accept($0.id)
                                                        popUpView.isLoading.accept(false)
                                                    })
                                                    .disposed(by: self.disposeBag)
                                            })
                                            .disposed(by: self.disposeBag)
                                    }
                                } else {
                                    print("이상한 에러")
                                    popUpView.isLoading.accept(false)
                                    popUpView.kakaoLoginButton.setTitle("카카오 로그인", for: .normal)
                                }
                            })
                            .disposed(by: self.disposeBag)
                    } else {
                        if (UserApi.isKakaoTalkLoginAvailable()) {
                            UserApi.shared.rx.loginWithKakaoTalk()
                                .subscribe(onNext: { [unowned self] _ in
                                    UserApi.shared.rx.me()
                                        .subscribe(onSuccess: {[unowned self] in
                                            self.email.accept($0.kakaoAccount?.email)
                                            self.kakaoId.accept($0.id)
                                            popUpView.isLoading.accept(false)
                                        })
                                        .disposed(by: disposeBag)
                                })
                                .disposed(by: disposeBag)
                        } else {
                            UserApi.shared.rx.loginWithKakaoAccount()
                                .subscribe(onNext: { [unowned self] _ in
                                    UserApi.shared.rx.me()
                                        .subscribe(onSuccess: {[unowned self] in
                                            self.email.accept($0.kakaoAccount?.email)
                                            self.kakaoId.accept($0.id)
                                            popUpView.isLoading.accept(false)
                                        })
                                        .disposed(by: disposeBag)
                                })
                                .disposed(by: disposeBag)
                        }
                    }
                })
                .disposed(by: disposeBag)
            // 애플로그인
            popUpView.appleLoginButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    UserDefaults.standard.setValue(K.SocialLogin.apple, forKey: K.SocialLogin.socialLogin)
                    popUpView.socialLogin.onNext(.apple)
                    popUpView.isLoading.accept(true)
                    self?.handleAppleLogin()
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
            self.appleIdentityToken.accept(tokenString)
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
