//
//  PopUpViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/16.
//

import UIKit
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser

class PopUpViewController: BaseViewController {

    // MARK: - Subviews
    lazy var popUpView = self.isLoginPopUp ? LoginPopUpView() : PopUpView(isChoice: self.isChoice)
    
    // MARK: - Properties
    var isLoginPopUp: Bool
    var isChoice: Bool
    
    // MARK: - Initialization
    init(isLoginPopUp: Bool, isChoice: Bool) {
        self.isLoginPopUp = isLoginPopUp
        self.isChoice = isChoice
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
                make.height.equalTo(158)
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
                .drive(onNext: {[unowned self] in
                    if (UserApi.isKakaoTalkLoginAvailable()) {
                        UserApi.shared.rx.loginWithKakaoTalk()
                            .subscribe(onNext:{ (oauthToken) in
                                print("loginWithKakaoTalk() success.")
                            
                                //do something
                                let tokens = oauthToken
                                print("IDTOKEN: \(tokens.idToken)")
                                print(tokens)
                            }, onError: {error in
                                print(error)
                            })
                            .disposed(by: self.disposeBag)
                    }
                })
                .disposed(by: disposeBag)
        }
        UserApi.shared.rx.me()
            .asObservable()
            .subscribe(onNext: {
                print("USER: \($0.kakaoAccount)")
            })
            .disposed(by: disposeBag)
    }
}
