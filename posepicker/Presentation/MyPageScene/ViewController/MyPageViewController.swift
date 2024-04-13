//
//  MyPageViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import RxKakaoSDKUser

class MyPageViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews
    let loginButton = UIButton(type: .system)
        .then {
            $0.backgroundColor = .violet050
            $0.layer.cornerRadius = 16
        }
    
    let loginLogo = UIImageView(image: ImageLiteral.imgLoginLogo)
    let loginLogoStar = UIImageView(image: ImageLiteral.imgLoginLogoStar)
    
    let loginTitle = UILabel()
        .then {
            $0.font = .subTitle1
            $0.textColor = .textPrimary
            $0.text = "회원가입 / 로그인"
        }
    
    let loginSubTitle = UILabel()
        .then {
            $0.font = .subTitle3
            $0.textColor = .gray500
            $0.text = "간편 로그인으로 3초만에 가입할 수 있어요."
        }
    
    let emailLabel = UILabel()
        .then {
            $0.textColor = .textPrimary
            $0.font = .pretendard(.medium, ofSize: 16)
        }
    
    let menuButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    
    let noticeButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("공지사항", for: .normal)
        }
    
    let faqButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("자주 묻는 질문", for: .normal)
        }
    
    let snsButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textBrand, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("포즈피커 공식 SNS", for: .normal)
        }
    
    let serviceUsageInquiryButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("문의하기", for: .normal)
        }
    
    let serviceInformationButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.setTitle("이용약관", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    
    let privacyInformationButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.setTitle("개인정보 처리방침", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    
    let logoutButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.setTitle("로그아웃", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
//            $0.isHidden = !AppCoordinator.loginState
        }
    
    let signoutButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textTertiary, for: .normal)
            $0.setTitle("탈퇴하기", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
//            $0.isHidden = !AppCoordinator.loginState
        }
    
    let loginToast = Toast(title: "로그인 되었습니다!")
    let logoutToast = Toast(title: "로그아웃 되었습니다!")
    let revokeToast = Toast(title: "탈퇴가 완료되었습니다.")
    
    // MARK: - Properties
    var viewModel: MyPageViewModel?

    let appleIdentityTokenTrigger = PublishSubject<String>()
    let kakaoEmailTrigger = PublishSubject<String>()
    let kakaoIdTrigger = PublishSubject<Int64>()
    let logoutTrigger = PublishSubject<Void>()
    let revokeTrigger = PublishSubject<String>()
    
    let loginStateTrigger = PublishSubject<Void>() // 로그인 취소되면 UI 복구목적
    
    // MARK: - Life Cycles
    
    // MARK: - Functions
    override func configUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        self.navigationController?.isNavigationBarHidden = false
        self.title = "메뉴"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .bgWhite
        
        
        if let email = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.email) {
            emailLabel.text = email
        } else {
            emailLabel.text = ""
        }
        
        adjustLoginUI(isLoggedIn: UserDefaults.standard.bool(forKey: K.SocialLogin.isLoggedIn))
        
        setBottomBorder()
    }
    
    override func render() {
        view.addSubViews([loginButton, loginLogo, loginLogoStar, loginTitle, loginSubTitle, emailLabel, noticeButton, faqButton, snsButton, serviceUsageInquiryButton, serviceInformationButton, privacyInformationButton, logoutButton, signoutButton, loginToast, logoutToast, revokeToast])
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(88)
        }
        
        loginLogo.snp.makeConstraints { make in
            make.centerY.equalTo(loginButton)
            make.leading.equalTo(loginButton)
            make.width.height.equalTo(60)
        }
        
        loginLogoStar.snp.makeConstraints { make in
            make.centerY.equalTo(loginButton)
            make.leading.equalTo(loginButton).offset(20)
            make.width.height.equalTo(40)
        }
        
        loginTitle.snp.makeConstraints { make in
            make.leading.equalTo(loginLogo.snp.trailing).offset(16)
            make.top.equalTo(loginLogo).offset(8)
        }
        
        loginSubTitle.snp.makeConstraints { make in
            make.bottom.equalTo(loginLogo).offset(-8)
            make.leading.equalTo(loginTitle)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(loginLogoStar)
            make.leading.equalTo(loginLogoStar.snp.trailing).offset(16)
        }
        
        noticeButton.snp.makeConstraints { make in
            make.leading.equalTo(loginButton)
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        faqButton.snp.makeConstraints { make in
            make.leading.equalTo(loginButton)
            make.top.equalTo(noticeButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        snsButton.snp.makeConstraints { make in
            make.leading.equalTo(faqButton)
            make.top.equalTo(faqButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        serviceUsageInquiryButton.snp.makeConstraints { make in
            make.leading.equalTo(snsButton)
            make.top.equalTo(snsButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        serviceInformationButton.snp.makeConstraints { make in
            make.leading.equalTo(serviceUsageInquiryButton)
            make.top.equalTo(serviceUsageInquiryButton.snp.bottom).offset(36)
            make.height.equalTo(24)
        }
        
        privacyInformationButton.snp.makeConstraints { make in
            make.leading.equalTo(serviceInformationButton)
            make.top.equalTo(serviceInformationButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.leading.equalTo(privacyInformationButton)
            make.top.equalTo(privacyInformationButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        signoutButton.snp.makeConstraints { make in
            make.leading.equalTo(logoutButton)
            make.top.equalTo(logoutButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        loginToast.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.bottom.equalTo(view).offset(46)
            make.centerX.equalTo(view)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        logoutToast.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.bottom.equalTo(view).offset(46)
            make.centerX.equalTo(view)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        revokeToast.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.bottom.equalTo(view).offset(46)
            make.centerX.equalTo(view)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    override func bindViewModel() {
        let input = MyPageViewModel.Input(
            noticeButtonTapEvent: noticeButton.rx.tap.asObservable(),
            faqButtonTapEvent: faqButton.rx.tap.asObservable(),
            snsButtonTapEvent: snsButton.rx.tap.asObservable(),
            serviceInquiryButtonTapEvent: serviceUsageInquiryButton.rx.tap.asObservable(),
            serviceInformationButtonTapEvent: serviceInformationButton.rx.tap.asObservable(),
            privacyInformationButtonTapEvent: privacyInformationButton.rx.tap.asObservable(),
            logoutButtonTapEvent: logoutButton.rx.tap.asObservable(),
            signoutButtonTapEvent: signoutButton.rx.tap.asObservable(),
            loginButtonTapEvent: loginButton.rx.tap.asObservable()
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
//        let input = MyPageViewModel.Input(appleIdentityTokenTrigger: appleIdentityTokenTrigger, kakaoLoginTrigger: Observable.combineLatest(kakaoEmailTrigger, kakaoIdTrigger), logoutButtonTapped: logoutTrigger, revokeButtonTapped: revokeTrigger)
//        let output = viewModel.transform(input: input)
//        
//        // 로그인할때
//        output.dismissLoginView
//            .subscribe(onNext: { [unowned self] in
//                if let popupVC = self.presentedViewController as? PopUpViewController {
//                    // 로그인할때
//                    if let _ = popupVC.popUpView as? LoginPopUpView {
//                        self.dismiss(animated: true) {
//                            self.loginToast.snp.updateConstraints { make in
//                                make.bottom.equalTo(self.view).offset(-60)
//                            }
//                            
//                            UIView.animate(withDuration: 0.2) {
//                                self.view.layoutIfNeeded()
//                                self.loginToast.layer.opacity = 1
//                            }
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                self.loginToast.snp.updateConstraints { make in
//                                    make.bottom.equalTo(self.view).offset(46)
//                                }
//                                
//                                UIView.animate(withDuration: 0.2) {
//                                    self.view.layoutIfNeeded()
//                                    self.loginToast.layer.opacity = 0
//                                }
//                            }
//                        }
//                        self.loginStateTrigger.onNext(())
//                    } else if let popupView = popupVC.popUpView as? PopUpView,
//                              popupView.alertMainLabel.text! == "로그아웃" {
//                        self.dismiss(animated: true) {
//                            self.logoutToast.snp.updateConstraints { make in
//                                make.bottom.equalTo(self.view).offset(-60)
//                            }
//                            
//                            UIView.animate(withDuration: 0.2) {
//                                self.view.layoutIfNeeded()
//                                self.logoutToast.isHidden = false
//                                self.logoutToast.layer.opacity = 1
//                            }
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                self.logoutToast.snp.updateConstraints { make in
//                                    make.bottom.equalTo(self.view).offset(46)
//                                }
//                                
//                                UIView.animate(withDuration: 0.2) {
//                                    self.view.layoutIfNeeded()
//                                    self.logoutToast.layer.opacity = 0
//                                }
//                            }
//                        }
//                        self.loginStateTrigger.onNext(())
//                    }
//                    
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        loginStateTrigger.asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] in
//                
//                // 로그인 상태 새로고침
//                if let email = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.email) {
//                    self?.emailLabel.text = email
//                    self?.adjustLoginUI(isLoggedIn: true)
//                } else {
//                    self?.adjustLoginUI(isLoggedIn: false)
//                }
//                
//                guard let navigationVC = self?.coordinator.rootViewController.viewControllers.last as? UINavigationController,
//                      let posefeedVC = navigationVC.viewControllers.first as? PoseFeedViewController else { return }
//                self?.coordinator.posefeedCoordinator.poseFeedFilterViewController.detailViewDismissTrigger.onNext(())
//                posefeedVC.tagResetTrigger.onNext(())
//            })
//            .disposed(by: disposeBag)
//        
//        output.revokeToastTrigger
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] in
//                guard let self = self else { return }
//                self.revokeToast.snp.updateConstraints { make in
//                    make.bottom.equalTo(self.view).offset(-60)
//                }
//                
//                UIView.animate(withDuration: 0.2) {
//                    self.view.layoutIfNeeded()
//                    self.revokeToast.isHidden = false
//                    self.revokeToast.layer.opacity = 1
//                }
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    self.revokeToast.snp.updateConstraints { make in
//                        make.bottom.equalTo(self.view).offset(46)
//                    }
//                    
//                    UIView.animate(withDuration: 0.2) {
//                        self.view.layoutIfNeeded()
//                        self.revokeToast.layer.opacity = 0
//                    }
//                }
//                
//                self.loginStateTrigger.onNext(())
//            })
//            .disposed(by: disposeBag)
    }
    
    func setBottomBorder() {
        let logoutLineView = UIView(frame: .init(x: 0, y: logoutButton.intrinsicContentSize.height - 8, width: logoutButton.intrinsicContentSize.width, height: 1))
        logoutLineView.backgroundColor = .init(hex: "#A9ABB8")
        logoutButton.addSubview(logoutLineView)
    }
    
    func adjustLoginUI(isLoggedIn: Bool) {
        if isLoggedIn {
            self.loginButton.backgroundColor = .violet050
            self.loginLogoStar.isHidden = false
            self.loginLogo.isHidden = true
            self.loginButton.isEnabled = false
            self.emailLabel.isHidden = false
            self.loginTitle.isHidden = true
            self.loginSubTitle.isHidden = true
            self.logoutButton.isHidden = false
            self.signoutButton.isHidden = false
        } else {
            self.loginButton.backgroundColor = .clear
            self.loginLogoStar.isHidden = true
            self.loginLogo.isHidden = false
            self.loginButton.isEnabled = true
            self.emailLabel.isHidden = true
            self.loginTitle.isHidden = false
            self.loginSubTitle.isHidden = false
            self.logoutButton.isHidden = true
            self.signoutButton.isHidden = true
        }
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

private extension MyPageViewController {
    func configureOutput(_ output: MyPageViewModel.Output?) {
        output?.refreshLoginState
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                // 로그인 완료 토스트 띄우기
                guard let self = self else { return }
                self.adjustLoginUI(isLoggedIn: $0)
                
                if let email = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.email) {
                    self.emailLabel.text = email
                }
                
                if $0 {
                    self.loginToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(-60)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.loginToast.isHidden = false
                        self.loginToast.layer.opacity = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.loginToast.snp.updateConstraints { make in
                            make.bottom.equalTo(self.view).offset(46)
                        }
                        
                        UIView.animate(withDuration: 0.2) {
                            self.view.layoutIfNeeded()
                            self.loginToast.layer.opacity = 0
                        }
                    }
                } else {
                    // 로그아웃 토스트 띄우기
                    self.logoutToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(-60)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.logoutToast.isHidden = false
                        self.logoutToast.layer.opacity = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.logoutToast.snp.updateConstraints { make in
                            make.bottom.equalTo(self.view).offset(46)
                        }
                        
                        UIView.animate(withDuration: 0.2) {
                            self.view.layoutIfNeeded()
                            self.logoutToast.layer.opacity = 0
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.revokeCompleted
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.adjustLoginUI(isLoggedIn: false)
                
                self.revokeToast.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view).offset(-60)
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                    self.revokeToast.isHidden = false
                    self.revokeToast.layer.opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.revokeToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(46)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.revokeToast.layer.opacity = 0
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
