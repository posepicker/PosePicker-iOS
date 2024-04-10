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
    
    func loginWithKakao()
    func loginWithApple(idToken: String)
    func logout(with: LoginPopUpView.SocialLogin)
    func revoke()
}
