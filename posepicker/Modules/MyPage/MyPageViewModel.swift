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
    
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    
    struct Input {
        var appleIdToken: Observable<String>
    }
    
    struct Output { 
        let user: Driver<User?>
    }
    
    func transform(input: Input) -> Output {
        let user = BehaviorRelay<User?>(value: nil)
        
        /// 1. 애플 아이디토큰 세팅 후 로그인
        input.appleIdToken
            .flatMapLatest { [unowned self] token -> Observable<User> in
                return self.apiSession.requestSingle(.appleLogin(idToken: token)).asObservable()
            }
            .subscribe(onNext: {
                user.accept($0)
            })
            .disposed(by: disposeBag)
        
        return Output(user: user.asDriver())
    }
}
