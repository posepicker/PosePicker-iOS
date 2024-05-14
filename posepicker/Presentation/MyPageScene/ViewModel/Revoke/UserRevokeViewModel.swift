//
//  UserRevokeViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import Foundation
import RxSwift
import RxRelay

final class UserRevokeViewModel {
    weak var coordinator: MyPageCoordinator?
    private let commonUseCase: CommonUseCase
    
    init(coordinator: MyPageCoordinator?, commonUseCase: CommonUseCase) {
        self.coordinator = coordinator
        self.commonUseCase = commonUseCase
    }
    
    struct Input {
        let revokeButtonTapEvent: Observable<Void>
        let revokeCancelButtonTapEvent: Observable<Void>
        let revokeReason: BehaviorRelay<String>
    }
    
    struct Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.revokeButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _) -> Observable<LoginPopUpView.SocialLogin?> in
                guard let coordinator = owner.coordinator else { return .empty() }
                return coordinator.presentRevokeConfirmPopup(disposeBag: disposeBag)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                output.isLoading.accept(true)
                switch $0 {
                case .apple:
                    self?.commonUseCase.revoke(with: .apple, reason: input.revokeReason.value)
                case .kakao:
                    self?.commonUseCase.revoke(with: .kakao, reason: input.revokeReason.value)
                default:
                    break
                }
                self?.coordinator?.popRevokeView()
            })
            .disposed(by: disposeBag)
        
        input.revokeCancelButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.popRevokeView()
            })
            .disposed(by: disposeBag)
        
        self.commonUseCase
            .revokeCompleted
            .subscribe(onNext: {
                output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
