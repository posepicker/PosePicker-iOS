//
//  MockCommonUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
import RxSwift
@testable import posepicker

final class MockCommonUseCase: CommonUseCase {
    var loginCompleted = PublishSubject<Void>()
    
    var logoutCompleted = PublishSubject<Void>()
    
    var revokeCompleted = PublishSubject<Void>()
    
    func logout(with: posepicker.LoginPopUpView.SocialLogin) {
        return
    }
    
    func revoke(with: posepicker.LoginPopUpView.SocialLogin, reason: String) {
        return
    }
    
    func loginWithKakao() {
        print("카카오 로그인 완료")
    }
    
    func loginWithApple(idToken: String) {
        print("애플 로그인 완료")
    }
}
