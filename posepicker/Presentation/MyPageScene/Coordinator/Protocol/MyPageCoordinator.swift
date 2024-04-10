//
//  File.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift

protocol MyPageCoordinator: Coordinator {
    var loginDelegate: CoordinatorLoginDelegate? { get set }
    func pushWebView(webView: WebViewList)
    func presentLogoutPopup(disposeBag: DisposeBag) -> Observable<LoginPopUpView.SocialLogin?>
    func pushRevokeQuestionView()
    func presentRevokeConfirmPopup(disposeBag: DisposeBag) -> Observable<LoginPopUpView.SocialLogin?>
    func popRevokeView()
}
