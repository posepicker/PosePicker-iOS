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

class MyPageViewController: BaseViewController {
    
    // MARK: - Subviews
    let loginButton = UIButton(type: .system)
        .then {
            $0.backgroundColor = .violet050
            $0.layer.cornerRadius = 16
        }
    
    let loginLogo = UIImageView(image: ImageLiteral.imgLoginLogo)
    
    let loginTitle = UILabel()
        .then {
            $0.font = .pretendard(.medium, ofSize: 16)
            $0.textColor = .textPrimary
            $0.text = "로그인하기"
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
    
    let privacyInforationButton = UIButton(type: .system)
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
            $0.isHidden = !AppCoordinator.loginState
        }
    
    let signoutButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textTertiary, for: .normal)
            $0.setTitle("탈퇴하기", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.isHidden = !AppCoordinator.loginState
        }
    
    // MARK: - Properties
    var viewModel: MyPageViewModel
    var coordinator: RootCoordinator
    
    let appleIdentityTokenTrigger = PublishSubject<String>()
    let kakaoEmailTrigger = PublishSubject<String>()
    let kakaoIdTrigger = PublishSubject<Int64>()
    
    let loginStateTrigger = PublishSubject<Void>()
    
    // MARK: - Life Cycles
    
    init(viewModel: MyPageViewModel, coordinator: RootCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func configUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        self.navigationController?.isNavigationBarHidden = false
        self.title = "메뉴"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = .bgWhite
        
        
        if let email = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.email) {
            loginButton.isEnabled = false
            loginTitle.text = email
        }
        
        
        loginButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                
                let popUpVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
                popUpVC.modalTransitionStyle = .crossDissolve
                popUpVC.modalPresentationStyle = .overFullScreen
                self.present(popUpVC, animated: true)
                
                popUpVC.appleIdentityToken
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.appleIdentityTokenTrigger.onNext($0)
                    })
                    .disposed(by: self.disposeBag)
                
                popUpVC.email
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.kakaoEmailTrigger.onNext($0)
                    })
                    .disposed(by: disposeBag)
                
                popUpVC.kakaoId
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.kakaoIdTrigger.onNext($0)
                    })
                    .disposed(by: disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        serviceUsageInquiryButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: true)
                popupViewController.modalTransitionStyle = .crossDissolve
                popupViewController.modalPresentationStyle = .overFullScreen
                let popupView = popupViewController.popUpView as! PopUpView
                popupView.alertText.accept("문의사항을 남기시겠습니까?")
                
                popupView.confirmButton.rx.tap.asDriver()
                    .drive(onNext: { [weak self] in
                        self?.coordinator.pushWebView(urlString: "https://litt.ly/posepicker", pageTitle: "문의하기")
                        popupViewController.dismiss(animated: true)
                    })
                    .disposed(by: self.disposeBag)
                
                popupView.cancelButton.rx.tap.asDriver()
                    .drive(onNext: {
                        popupViewController.dismiss(animated: true)
                    })
                    .disposed(by: self.disposeBag)
                
                self.present(popupViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        noticeButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator.pushWebView(urlString: "https://shineshine.notion.site/fde248040bed45f68fbfa3004e2c4856", pageTitle: "공지사항")
            })
            .disposed(by: disposeBag)
        
        faqButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator.pushWebView(urlString: "https://shineshine.notion.site/cc71decc2e534ae6abb195bb10a501c0", pageTitle: "자주 묻는 질문")
            })
            .disposed(by: disposeBag)
        
        snsButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator.pushWebView(urlString: "https://www.instagram.com/posepicker?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==", pageTitle: "포즈피커 공식 SNS")
            })
            .disposed(by: disposeBag)
        
        serviceInformationButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator.pushWebView(urlString: "https://shineshine.notion.site/3113eb146abb4b5c809070c3f01380da", pageTitle: "이용약관")
            })
            .disposed(by: disposeBag)
        
        privacyInforationButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator.pushWebView(urlString: "https://shineshine.notion.site/75e98a2462824b839a9c37473a6afbd5", pageTitle: "개인정보 처리방침")
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
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
                        self?.dismiss(animated: true)
                    })
                    .disposed(by: disposeBag)
                
                popupView.cancelButton.rx.tap.asDriver()
                    .drive(onNext: { [weak self] in
                        guard let self = self else { return }
                        UserApi.shared.rx.logout()
                            .subscribe(onCompleted: {
                                print("kakao logout completed")
                            })
                            .disposed(by: self.disposeBag)
                        
                        KeychainManager.shared.removeAll()
                        self.loginStateTrigger.onNext(())
                        self.dismiss(animated: true)
                    })
                    .disposed(by: disposeBag)
                
                self.present(popupViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        signoutButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: true, isLabelNeeded: true, isSignout: true)
                popupViewController.modalTransitionStyle = .crossDissolve
                popupViewController.modalPresentationStyle = .overFullScreen
                let popupView = popupViewController.popUpView as! PopUpView
                popupView.alertMainLabel.text = "회원탈퇴"
                popupView.alertText.accept("모든 데이터는 삭제되며\n재가입하더라도 복구할 수 없어요.\n정말 탈퇴하시겠어요?")
                popupView.confirmButton.setTitle("로그인 유지", for: .normal)
                popupView.cancelButton.setTitle("회원탈퇴", for: .normal)
                
                popupView.confirmButton.rx.tap.asDriver()
                    .drive(onNext: { [weak self] in
                        self?.dismiss(animated: true)
                    })
                    .disposed(by: disposeBag)
                
                popupView.cancelButton.rx.tap.asDriver()
                    .drive(onNext: { [weak self] in
                        guard let self = self else { return }
                        UserApi.shared.rx.unlink()
                            .subscribe(onCompleted: {
                                print("kakao unlink completed")
                            })
                            .disposed(by: self.disposeBag)
                        
                        KeychainManager.shared.removeAll()
                        self.loginStateTrigger.onNext(())
                        self.dismiss(animated: true)
                    })
                    .disposed(by: disposeBag)
                
                self.present(popupViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        setBottomBorder()
    }
    
    override func render() {
        view.addSubViews([loginButton, loginLogo, loginTitle, noticeButton, faqButton, snsButton, serviceUsageInquiryButton, serviceInformationButton, privacyInforationButton, logoutButton, signoutButton])
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(88)
        }
        
        loginLogo.snp.makeConstraints { make in
            make.centerY.equalTo(loginButton)
            make.leading.equalTo(loginButton).offset(20)
        }
        
        loginTitle.snp.makeConstraints { make in
            make.leading.equalTo(loginLogo.snp.trailing).offset(16)
            make.centerY.equalTo(loginButton)
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
        
        privacyInforationButton.snp.makeConstraints { make in
            make.leading.equalTo(serviceInformationButton)
            make.top.equalTo(serviceInformationButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.leading.equalTo(privacyInforationButton)
            make.top.equalTo(privacyInforationButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        signoutButton.snp.makeConstraints { make in
            make.leading.equalTo(logoutButton)
            make.top.equalTo(logoutButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
    }
    
    override func bindViewModel() {
        let input = MyPageViewModel.Input(appleIdentityTokenTrigger: appleIdentityTokenTrigger, kakaoLoginTrigger: Observable.combineLatest(kakaoEmailTrigger, kakaoIdTrigger))
        let output = viewModel.transform(input: input)
        
        output.dismissLoginView
            .subscribe(onNext: { [unowned self] in
                guard let popupVC = self.presentedViewController as? PopUpViewController,
                      let _ = popupVC.popUpView as? LoginPopUpView else { return }
                self.dismiss(animated: true)
                self.loginStateTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        loginStateTrigger.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                if let email = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.email) {
                    self?.loginButton.isEnabled = false
                    self?.loginTitle.text = email
                    self?.logoutButton.isHidden = false
                    self?.signoutButton.isHidden = false
                } else {
                    self?.loginButton.isEnabled = true
                    self?.loginTitle.text = "로그인하기"
                    self?.logoutButton.isHidden = true
                    self?.signoutButton.isHidden = true
                }
                
                guard let navigationVC = self?.coordinator.rootViewController.viewControllers.last as? UINavigationController,
                      let posefeedVC = navigationVC.viewControllers.first as? PoseFeedViewController else { return }
                self?.coordinator.posefeedCoordinator.poseFeedFilterViewController.detailViewDismissTrigger.onNext(())
                posefeedVC.tagResetTrigger.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func setBottomBorder() {
        let logoutLineView = UIView(frame: .init(x: 0, y: logoutButton.intrinsicContentSize.height - 8, width: logoutButton.intrinsicContentSize.width, height: 1))
        logoutLineView.backgroundColor = .init(hex: "#A9ABB8")
        logoutButton.addSubview(logoutLineView)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
