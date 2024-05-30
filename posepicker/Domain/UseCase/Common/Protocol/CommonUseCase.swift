//
//  CommonUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation
import RxSwift

protocol CommonUseCase {
    var loginCompleted: PublishSubject<Void> { get set }
    var logoutCompleted: PublishSubject<Void> { get set }
    var revokeCompleted: PublishSubject<Void> { get set }
    
    func loginWithKakao()
    func loginWithApple()
    func logout(with: LoginPopUpView.SocialLogin)
    func revoke(with: LoginPopUpView.SocialLogin, reason: String)
}
