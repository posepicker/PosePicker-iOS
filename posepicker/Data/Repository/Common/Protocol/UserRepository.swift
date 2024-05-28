//
//  UserRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation

import RxSwift
import KakaoSDKUser
import KakaoSDKAuth


protocol UserRepository {
    // MARK: - 카카오 로그인 to 포즈피커
    
    func loginWithKakao(
    ) -> Observable<PosePickerUser>
    
    // MARK: - 애플 로그인 to 포즈피커
    func loginWithApple(
        idToken: String             // 애플 아이덴티티 토큰
    ) -> Observable<PosePickerUser>
    
    // MARK: - 토큰 REFRESH/DELETE
    func reissueToken(
    ) -> Observable<Token>
    func logout(
        with: LoginPopUpView.SocialLogin,
        disposeBag: DisposeBag
    ) -> Observable<LogoutResponse>
    
    // MARK: - 탈퇴
    func deleteUserInfo(
        with: LoginPopUpView.SocialLogin,
        withdrawalReason: String,    // 탈퇴 사유
        disposeBag: DisposeBag
    ) -> Observable<MeaninglessResponse>
}
