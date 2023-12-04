//
//  MyPageViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

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
    
    let serviceUsageInquiryButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("서비스 이용문의", for: .normal)
        }
    
    let serviceInformationButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.setTitle("서비스 정보", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    
    // MARK: - Properties
    var viewModel: MyPageViewModel
    var coordinator: RootCoordinator
    
    var appleIdTokenSubject = PublishSubject<String>()
    
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
        self.navigationController?.isNavigationBarHidden = false
        self.title = "메뉴"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = .bgWhite
    }
    
    override func render() {
        view.addSubViews([loginButton, loginLogo, loginTitle, serviceUsageInquiryButton, serviceInformationButton])
        
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
        
        serviceUsageInquiryButton.snp.makeConstraints { make in
            make.leading.equalTo(loginButton)
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
        
        serviceInformationButton.snp.makeConstraints { make in
            make.leading.equalTo(loginButton)
            make.top.equalTo(serviceUsageInquiryButton.snp.bottom).offset(24)
            make.height.equalTo(24)
        }
    }
    
    override func bindViewModel() {
        
        let input = MyPageViewModel.Input(appleIdToken: appleIdTokenSubject)
        let output = viewModel.transform(input: input)
        
        loginButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                let popUpVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
                popUpVC.modalTransitionStyle = .crossDissolve
                popUpVC.modalPresentationStyle = .overFullScreen
                self.present(popUpVC, animated: true)
                
                popUpVC.appleIdentityToken
                    .subscribe(onNext: { [unowned self] in
                        guard let token = $0 else { return }
                        self.appleIdTokenSubject.onNext(token)
                        popUpVC.dismiss(animated: true)
                    })
                    .disposed(by: self.disposeBag)
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
                    .drive(onNext: {
                        if let url = URL(string: "https://litt.ly/posepicker") {
                            UIApplication.shared.open(url)
                        }
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
        
        serviceInformationButton.rx.tap.asDriver()
            .drive(onNext: {
                if let url = URL(string: "https://shineshine.notion.site/a668d9eba61f48e584df2ad3a946c313") {
                    UIApplication.shared.open(url)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
