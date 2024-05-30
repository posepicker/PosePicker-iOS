//
//  DefaultCommonUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import RxKakaoSDKUser
import Alamofire

final class DefaultCommonUseCase: CommonUseCase {
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    var loginCompleted = PublishSubject<Void>()
    var logoutCompleted = PublishSubject<Void>()
    var revokeCompleted = PublishSubject<Void>()
    
    // 외부에서 목업 키체인 서비스 객체를 주입할 수 있어야됨
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loginWithKakao() {
        // 키체인은 어차피 목업으로 함께 주입되기 때문에 로직이 레파지토리 안에 포함되어 있어도 됨
        userRepository.loginWithKakao()
            .subscribe(onNext: { [weak self] _ in
                self?.loginCompleted.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func loginWithApple() {
        userRepository.loginWithApple()
            .subscribe(onNext: { [weak self] _ in
                self?.loginCompleted.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func logout(with: LoginPopUpView.SocialLogin) {
        UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
        userRepository.logout(with: with, disposeBag: disposeBag)
            .subscribe(onNext: { [weak self] in
                if $0.status >= 200 && $0.status <= 300 {
                    self?.logoutCompleted.onNext(())
                }
                
                if $0.status == 401 {
                    self?.logoutCompleted.onNext(())
                }
            }, onError: { error in
                if let error = error as? APIError,
                   error == .http(status: 401) {
                    self.logoutCompleted.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func revoke(with: LoginPopUpView.SocialLogin, reason: String) {
        userRepository.deleteUserInfo(
            with: with,
            withdrawalReason: reason,
            disposeBag: disposeBag
        )
        .catchAndReturn(MeaninglessResponse(entity: "", message: "", redirect: "", status: 500))
        .subscribe(onNext: { [weak self] in
            // 500에러 디버깅 필요..
            UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
            if $0.status >= 200 && $0.status <= 300 {
                self?.revokeCompleted.onNext(())
            }
            
            if $0.status == 500 {
                self?.revokeCompleted.onNext(())
            }
        })
        .disposed(by: disposeBag)
    }
}
