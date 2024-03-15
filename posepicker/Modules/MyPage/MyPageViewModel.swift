//
//  MyPageViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class MyPageViewModel: ViewModelType {
    
    var apiSession: APIService
    var disposeBag = DisposeBag()
    
    init(apiSession: APISession = APISession()) {
        self.apiSession = apiSession
    }

    struct Input {
        let appleIdentityTokenTrigger: Observable<String>
        let kakaoLoginTrigger: Observable<(String, Int64)>
        let logoutButtonTapped: Observable<Void>
        let revokeButtonTapped: Observable<String>
    }
    
    struct Output { 
        let dismissLoginView: Observable<Void>
        let revokeToastTrigger: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let dismissLoginView = PublishSubject<Void>()
        let kakaoAccountObservable = BehaviorRelay<(String, Int64)>(value: ("", -1))
        let authCodeObservable = BehaviorRelay<String>(value: "")
        let revokeTrigger = PublishSubject<Void>()
        
        /// 1.  애플 아이덴티티 토큰 세팅 후 로그인처리
        input.appleIdentityTokenTrigger
            .flatMapLatest { [unowned self] token -> Observable<PosePickerUser> in
                return self.apiSession.requestSingle(.appleLogin(idToken: token)).asObservable()
            }
            .flatMapLatest { user -> Observable<(Void, Void, Void, Void)> in
                let accessTokenObservable = KeychainManager.shared.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = KeychainManager.shared.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                let userIdObservable = KeychainManager.shared.rx.saveItem("\(user.id)", itemClass: .password, key: K.Parameters.userId)
                let emailObservable = KeychainManager.shared.rx.saveItem(Functions.nicknameFromEmail(user.email) + "님 반가워요!", itemClass: .password, key: K.Parameters.email)
                return Observable.zip(accessTokenObservable, refreshTokenObservable, userIdObservable, emailObservable)
            }
            .subscribe(onNext: { _ in
                dismissLoginView.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 2. 카카오 이메일 추출 후 로그인처리
        input.kakaoLoginTrigger
            .flatMapLatest { [unowned self] kakaoAccount -> Observable<AuthCode> in
                kakaoAccountObservable.accept(kakaoAccount)
                return self.apiSession.requestSingle(.retrieveAuthoirzationCode).asObservable()
            }
            .flatMapLatest {
                authCodeObservable.accept($0.token)
                return Observable.combineLatest(kakaoAccountObservable.asObservable(), authCodeObservable.asObservable())
            }
            .flatMapLatest { [unowned self] (params: ((String, Int64), String)) -> Observable<PosePickerUser> in
                let (email, kakaoId) = params.0
                let authCode = params.1
                return self.apiSession.requestSingle(.kakaoLogin(authCode: authCode, email: email, kakaoId: kakaoId)).asObservable()
            }
            .flatMapLatest { user -> Observable<(Void, Void, Void, Void)> in
                let accessTokenObservable = KeychainManager.shared.rx.saveItem(user.token.accessToken, itemClass: .password, key: K.Parameters.accessToken)
                let refreshTokenObservable = KeychainManager.shared.rx.saveItem(user.token.refreshToken, itemClass: .password, key: K.Parameters.refreshToken)
                let userIdObservable = KeychainManager.shared.rx.saveItem("\(user.id)", itemClass: .password, key: K.Parameters.userId)
                let emailObservable = KeychainManager.shared.rx.saveItem(user.email, itemClass: .password, key: K.Parameters.email)
                return Observable.zip(accessTokenObservable, refreshTokenObservable, userIdObservable, emailObservable)
            }
            .subscribe(onNext: { _ in
                dismissLoginView.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 로그아웃 API
        /// 로그아웃 이후 dismiss
        /// 기존 토큰은 삭제
        input.logoutButtonTapped
            .withUnretained(self)
            .flatMapLatest { (owner, _) -> Observable<LogoutResponse> in
                guard let accessToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.accessToken),
                      let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.refreshToken) else { return Observable<LogoutResponse>.empty() }
                return owner.apiSession.requestSingle(.logout(accessToken: accessToken, refreshToken: refreshToken)).asObservable()
            }
            .map { $0.status }
            .subscribe(onNext: { status in
                // 로그아웃 성공
                if status == 200 {
                    KeychainManager.shared.removeAll()
                    dismissLoginView.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        /// 탈퇴 API
        input.revokeButtonTapped
            .withUnretained(self)
            .flatMapLatest { owner, withdrawalReason -> Observable<RevokeResponse> in
                guard let accessToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.accessToken),
                      let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.refreshToken) else { return Observable<RevokeResponse>.empty() }
                return owner.apiSession.requestSingle(.revoke(accessToken: accessToken, refreshToken: refreshToken, withdrawalReason: withdrawalReason)).asObservable()
            }
            .map { $0.status }
            .subscribe(onNext: { status in
                if status >= 200 && status <= 300 {
                    KeychainManager.shared.removeAll()
                    revokeTrigger.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        return Output(dismissLoginView: dismissLoginView, revokeToastTrigger: revokeTrigger)
    }
}
