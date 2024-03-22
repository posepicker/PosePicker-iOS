//
//  UserRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation

import RxSwift

protocol UserRepository {
    // MARK: - 카카오 로그인 to 포즈피커
    func loginWithKakao(
        email: String,              // 이메일
        accessToken: String,        // 액세스 토큰
        refreshToken: String        // 리프레시 토큰
    ) -> Observable<PosePickerUser>
    
    // MARK: - 애플 로그인 to 포즈피커
    func loginWithApple(
        idToken: String             // 애플 아이덴티티 토큰
    ) -> Observable<PosePickerUser>
    
    // MARK: - 토큰 REFRESH/DELETE
    func reissueToken(
        refreshToken: String        // 리프레시 토큰
    ) -> Observable<Token>
    func logout(
        accessToken: String,        // 액세스 토큰
        refreshToken: String        // 리프레시 토큰
    ) -> Observable<MeaninglessResponse>
    
    // MARK: - 탈퇴
    func deleteUserInfo(
        accessToken: String,        // 액세스 토큰
        refreshToken: String,       // 리프레시 토큰
        withdrawalReason: String    // 탈퇴 사유
    ) -> Observable<MeaninglessResponse>
}