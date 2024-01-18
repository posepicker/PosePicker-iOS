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
    }
    
    struct Output { 
        let dismissLoginView: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let dismissLoginView = PublishSubject<Void>()
        let kakaoAccountObservable = BehaviorRelay<(String, Int64)>(value: ("", -1))
        let authCodeObservable = BehaviorRelay<String>(value: "")
        
        /// 1.  애플 아이덴티티 토큰 세팅 후 로그인처리
        input.appleIdentityTokenTrigger
            .flatMapLatest { [unowned self] token -> Observable<PosePickerUser> in
                return self.apiSession.requestSingle(.appleLogin(idToken: token)).asObservable()
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
        
        return Output(dismissLoginView: dismissLoginView)
    }
}
