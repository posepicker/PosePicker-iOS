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
    lazy var popUpView = self.isLoginPopUp ? LoginPopUpView() : PopUpView(isChoice: self.isChoice, isLabelNeeded: isLabelNeeded)
    
    // MARK: - Properties
    var isLoginPopUp: Bool
    var isChoice: Bool
    var isLabelNeeded: Bool
    
    /// Optional 타입이 아니면 초기에 next로 값이 방출되어버림
    let appleIdentityToken = BehaviorRelay<String?>(value: nil)
    let kakaoId = BehaviorRelay<Int64?>(value: nil)
    let email = BehaviorRelay<String?>(value: nil)

    // MARK: - Initialization
    init(isLoginPopUp: Bool, isChoice: Bool, isLabelNeeded: Bool = false) {
        self.isLoginPopUp = isLoginPopUp
        self.isChoice = isChoice
        self.isLabelNeeded = isLabelNeeded
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
                    if (AuthApi.hasToken()) {
                        UserApi.shared.rx.accessTokenInfo()
                            .subscribe(onSuccess: { _ in
                                UserApi.shared.rx.me()
                                    .subscribe(onSuccess: { [unowned self] in
                                        self.email.accept($0.kakaoAccount?.email)
                                        self.kakaoId.accept($0.id)
                                    })
                                    .disposed(by: self.disposeBag)
                            }, onFailure: { error in
                                if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                                    if (UserApi.isKakaoTalkLoginAvailable()) {
                                        UserApi.shared.rx.loginWithKakaoTalk()
                                            .flatMapLatest { _ in
                                                UserApi.shared.rx.me()
                                            }
                                            .subscribe(onNext: { [unowned self] in
                                                self.email.accept($0.kakaoAccount?.email)
                                                self.kakaoId.accept($0.id)
                                            })
                                            .disposed(by: self.disposeBag)
                                    }
                                } else {
                                    print("이상한 에러")
                                }
                            })
                            .disposed(by: self.disposeBag)
                    } else {
                        if (UserApi.isKakaoTalkLoginAvailable()) {
                            UserApi.shared.rx.loginWithKakaoTalk()
                                .flatMapLatest { _ in
                                    UserApi.shared.rx.me()
                                }
                                .subscribe(onNext: { [unowned self] in
                                    self.email.accept($0.kakaoAccount?.email)
                                    self.kakaoId.accept($0.id)
                                })
                                .disposed(by: self.disposeBag)
                        }
                    }
                })
                .disposed(by: disposeBag)
            
            // 애플로그인
            popUpView.appleLoginButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.handleAppleLogin()
                })
                .disposed(by: disposeBag)
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
}

extension PopUpViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
