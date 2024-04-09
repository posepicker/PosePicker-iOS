//
//  MyPageViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift

final class MyPageViewModel {
    weak var coordinator: MyPageCoordinator?
    private let myPageUseCase: MyPageUseCase
    
    init(coordinator: MyPageCoordinator?, myPageUseCase: MyPageUseCase) {
        self.coordinator = coordinator
        self.myPageUseCase = myPageUseCase
    }
    
    struct Input {
        let noticeButtonTapEvent: Observable<Void>
        let faqButtonTapEvent: Observable<Void>
        let snsButtonTapEvent: Observable<Void>
        let serviceInquiryButtonTapEvent: Observable<Void>
        let serviceInformationButtonTapEvent: Observable<Void>
        let privacyInformationButtonTapEvent: Observable<Void>
        let logoutButtonTapEventTapEvent: Observable<Void>
        let signoutButtonTapEventTapEvent: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.noticeButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .notice)
            })
            .disposed(by: disposeBag)
        
        input.faqButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .faq)
            })
            .disposed(by: disposeBag)
        
        input.snsButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .sns)
            })
            .disposed(by: disposeBag)
        
        input.serviceInquiryButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .serviceInquiry)
            })
            .disposed(by: disposeBag)
        
        input.serviceInformationButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .serviceInformation)
            })
            .disposed(by: disposeBag)
        
        input.privacyInformationButtonTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushWebView(webView: .privacyInformation)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
