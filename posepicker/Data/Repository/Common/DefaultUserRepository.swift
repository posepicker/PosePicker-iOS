//
//  DefaultUserRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/20/24.
//

import Foundation

import RxSwift
import RxRelay
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import RxKakaoSDKUser

final class DefaultUserRepository: UserRepository {
    
    let networkService: NetworkService
    let keychainService: KeychainService
    
    init(networkService: NetworkService, keychainService: KeychainService) {
        self.networkService = networkService
        self.keychainService = keychainService
    }
    
    /// 토큰 유효성 검사를 위해 서버로부터 자체 발급되는 JWT 로드
    /// JWT 가지고 카카오 로그인 요청을 진행해야됨
    private func fetchAuthCodeFromPosepicker() -> Observable<String> {
        return networkService.requestSingle(.retrieveAuthoirzationCode)
            .asObservable()
            .map { (authCode: AuthCode) in authCode.token }
    }
    
    /// 카카오 로그인 요청
    func loginWithKakao() -> Observable<PosePickerUser> {
        return Observable.combineLatest(
            self.fetchAuthCodeFromPosepicker(),
            self.loadKakaoInfo()
        )
        .flatMapLatest { [weak self] (authCode, kakaoInfo) -> Observable<PosePickerUser> in
            let (email, kakaoId) = kakaoInfo
            guard let self = self else { return .empty() }
            return self.networkService
                .requestSingle(.kakaoLogin(authCode: authCode, email: email, kakaoId: kakaoId))
                .asObservable()
                .flatMapLatest { [weak self] (user: PosePickerUser) -> Observable<PosePickerUser> in
                    
                    // 토큰 저장
                    self?.keychainService.saveToken(user.token)
                    self?.keychainService.saveEmail(user.email)
                    
                    UserDefaults.standard.setValue(true, forKey: K.SocialLogin.isLoggedIn)
                    UserDefaults.standard.setValue(K.SocialLogin.kakao, forKey: K.SocialLogin.socialLogin)
                    
                    return BehaviorRelay<PosePickerUser>(value: user).asObservable()
                }
        }
    }
    
    func loginWithApple(idToken: String) -> Observable<PosePickerUser> {
        return networkService.requestSingle(
            .appleLogin(
                idToken: idToken
            ))
        .asObservable()
        .flatMapLatest { [weak self] (user: PosePickerUser) -> Observable<PosePickerUser> in
            self?.keychainService.saveToken(user.token)
            self?.keychainService.saveEmail(user.email)
            
            UserDefaults.standard.setValue(true, forKey: K.SocialLogin.isLoggedIn)
            UserDefaults.standard.setValue(K.SocialLogin.apple, forKey: K.SocialLogin.socialLogin)
            
            return BehaviorRelay<PosePickerUser>(value: user).asObservable()
        }
    }
    
    func reissueToken(refreshToken: String) -> Observable<Token> {
        return networkService.requestSingle(
            .refreshToken(
                refreshToken: refreshToken
            ))
            .asObservable()
            .flatMapLatest { token -> Observable<Token> in
                return BehaviorRelay<Token>(value: token).asObservable()
            }
    }
    
    func logout(accessToken: String, refreshToken: String) -> Observable<LogoutResponse> {
        networkService.requestSingle(
            .logout(
                accessToken: accessToken,
                refreshToken: refreshToken
            )).asObservable()
            .flatMapLatest { response in
                UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
                UserDefaults.standard.removeObject(forKey: K.SocialLogin.socialLogin)
                return BehaviorRelay<LogoutResponse>(value: response).asObservable()
            }
    }
    
    func deleteUserInfo(accessToken: String, refreshToken: String, withdrawalReason: String) -> Observable<MeaninglessResponse> {
        return networkService.requestSingle(
            .revoke(
                accessToken: accessToken,
                refreshToken: refreshToken,
                withdrawalReason: withdrawalReason
            ))
        .asObservable()
        .flatMapLatest { response in
            UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
            UserDefaults.standard.removeObject(forKey: K.SocialLogin.socialLogin)
            return BehaviorRelay<MeaninglessResponse>(value: response).asObservable()
        }
        
    }
    
    // MARK: - 카카오 로그인 관련 함수들 모음집
    private func retrieveEmailAndKakaoIdFromUser(kakaoUser: User) -> Observable<(String, Int64)> {
        let greetText = "포즈피커 회원님 반가워요!"
        
        guard let kakaoId = kakaoUser.id else { return .empty() }
        
        let relay = BehaviorRelay<(String, Int64)>(value: ("",-1))
        if let email = kakaoUser.kakaoAccount?.email {
            relay.accept((email, kakaoId))
        } else if let nickname = kakaoUser.kakaoAccount?.profile?.nickname {
            relay.accept((nickname + "님 반가워요!", kakaoId))
        } else {
            relay.accept((greetText, kakaoId))
        }
        
        return relay.asObservable()
    }

    /// 0. 공통 - 이메일, 카카오 아이디 담는 API는 UserApi.shared.rx.me에서 데이터 추출
    /// 1. 토큰 여부 확인
    ///     1-1. 토큰 있으면 카카오 정보 요청 (fetchKakaoInfo)
    ///             1-1-1. 성공하면 **이메일 & 카카오 아이디 담아서 리턴**
    ///             1-1-2. 실패하면 **에러 타입 체크** ,  토큰 유효성 실패인 경우 카카오톡 앱으로 로그인하기
    ///                 1-1-2-1. 카카오톡 앱으로 로그인 가능한 경우 로그인 후 **이메일 & 카카오 아이디 담아서 리턴**
    ///                 1-1-2-2. 실패한 경우 앱이 아닌 웹으로 로그인 시도
    ///                     1-1-2-2-1. 성공하면 **이메일 & 카카오 아이디 담아서 리턴**
    ///             1-1-3. 에러타입 체크 후 토큰 유효성 관련 에러가 아닌 경우, 로그인 실패처리
    ///     1-2. 토큰 없으면 카카오톡 앱으로 로그인
    ///             1-2-1. 앱으로 로그인 가능하면 로그인 후 **이메일 & 카카오 아이디 담아서 리턴**
    ///             1-2-2. 앱으로 로그인 불가능하면 웹으로 로그인 시도, **이메일 & 카카오 아이디 담아서 리턴**
    private func loadKakaoInfo() -> Observable<(String, Int64)> {
        if (AuthApi.hasToken()) {
            return self.fetchKakaoAccessTokenInfo()
                .flatMapLatest { [weak self] _ -> Observable<User> in
                    guard let self = self else { return Observable<User>.empty() }
                    return self.fetchKakaoInfo()
                        .catch { [weak self] error in
                            guard let self = self else { return Observable<User>.empty() }
                            
                            /// 토큰 존재한 상황인데, 만료된 경우 카카오톡 로그인 재요청 하도록 에러처리 하는 부분
                            /// 초기 fetchKakaoInfo에서 flatMapLatest 하기 전에 catch하여 옵저버블 <User> 리턴
                            if let sdkError = error as? SdkError,
                               sdkError.isInvalidTokenError() == true {
                                if UserApi.isKakaoTalkLoginAvailable() {
                                    return UserApi.shared.rx.loginWithKakaoTalk()
                                        .flatMapLatest { [weak self] _ -> Observable<User> in
                                            guard let self = self else { return Observable<User>.empty() }
                                            return self.fetchKakaoInfo()
                                        }
                                } else {
                                    return UserApi.shared.rx.loginWithKakaoAccount()
                                        .flatMapLatest { [weak self] _ -> Observable<User> in
                                            guard let self = self else { return Observable<User>.empty() }
                                            return self.fetchKakaoInfo()
                                        }
                                }
                            }
                            else {
                                /// 토큰 유효성 검사 에러가 아니면 empty 리턴
                                return Observable<User>.empty()
                            }
                        }
                }
                .flatMapLatest { [weak self] kakaoUser -> Observable<(String, Int64)> in
                    guard let self = self else { return .empty() }
                    return self.retrieveEmailAndKakaoIdFromUser(kakaoUser: kakaoUser)
                }
        } else {
            if UserApi.isKakaoTalkLoginAvailable() {
                return UserApi.shared.rx.loginWithKakaoTalk()
                    .flatMapLatest { [weak self] _ -> Observable<User> in
                        guard let self = self else { return Observable<User>.empty() }
                        return self.fetchKakaoInfo()
                    }
                    .flatMapLatest { [weak self] kakaoUser -> Observable<(String, Int64)> in
                        guard let self = self else { return .empty() }
                        return self.retrieveEmailAndKakaoIdFromUser(kakaoUser: kakaoUser)
                    }
            } else {
                return UserApi.shared.rx.loginWithKakaoAccount()
                    .flatMapLatest { [weak self] _ -> Observable<User> in
                        guard let self = self else { return Observable<User>.empty() }
                        return self.fetchKakaoInfo()
                    }
                    .flatMapLatest { [weak self] kakaoUser -> Observable<(String, Int64)> in
                        guard let self = self else { return .empty() }
                        return self.retrieveEmailAndKakaoIdFromUser(kakaoUser: kakaoUser)
                    }
            }
        }
    }
    
    private func loginWithKakaoTalk() -> Observable<OAuthToken> {
        return UserApi.shared.rx.loginWithKakaoTalk()
    }
    
    /// 토큰 유효성 검사 후 success case인 경우 UserApi.shared.rx.me() 호출을 위한 목적
    /// failure case로 분류된 경우 카카오톡 어플로 로그인 다시 시도
    private func fetchKakaoAccessTokenInfo() -> Observable<AccessTokenInfo> {
        return UserApi.shared.rx.accessTokenInfo().asObservable()
    }
    
    /// 토큰 유효성 검사 이후 카카오 서버에 등록된 사용자 정보 가져오기
    /// 이메일 & 카카오 UID 추출하는게 목표
    private func fetchKakaoInfo() -> Observable<User> {
        return UserApi.shared.rx.me().asObservable()
    }
}
