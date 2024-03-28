//
//  CommonUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation

protocol CommonUseCase {
    func loginWithKakao()
    func loginWithApple(idToken: String)
}
