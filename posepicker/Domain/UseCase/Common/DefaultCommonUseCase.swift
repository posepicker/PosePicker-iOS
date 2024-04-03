//
//  DefaultCommonUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation
import RxSwift

final class DefaultCommonUseCase: CommonUseCase {
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    
    let loginCompletedTrigger = PublishSubject<Void>()

    // 외부에서 목업 키체인 서비스 객체를 주입할 수 있어야됨
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loginWithKakao() {
        // 키체인은 어차피 목업으로 함께 주입되기 때문에 로직이 레파지토리 안에 포함되어 있어도 됨
        userRepository.loginWithKakao()
            .subscribe(onNext: { [weak self] _ in
                self?.loginCompletedTrigger.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func loginWithApple(idToken: String) {
        userRepository.loginWithApple(idToken: idToken)
            .subscribe(onNext: { [weak self] _ in
                self?.loginCompletedTrigger.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    
}
