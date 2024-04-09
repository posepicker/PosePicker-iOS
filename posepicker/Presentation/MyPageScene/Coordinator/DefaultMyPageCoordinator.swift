//
//  DefaultMyPageCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import UIKit

final class DefaultMyPageCoordinator: MyPageCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var myPageViewController: MyPageViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.myPageViewController = MyPageViewController()
    }
    
    func start() {
        self.myPageViewController.viewModel = MyPageViewModel(
            coordinator: self,
            myPageUseCase: DefaultMyPageUseCase()
        )
        self.navigationController.pushViewController(myPageViewController, animated: true)
    }
    
    func pushWebView(webView: WebViewList) {
        var mypageWebviewVC: MypageWebViewController!
        print(webView)
        switch webView {
        case .notice:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "공지사항"
            )
            
        case .faq:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "자주 묻는 질문"
            )
        case .sns:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "포즈피드 공식 SNS"
            )
        case .serviceInquiry:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "문의하기"
            )
        case .serviceInformation:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "이용약관"
            )
        case .privacyInformation:
            mypageWebviewVC = MypageWebViewController(
                urlString: webView.rawValue,
                pageTitle: "개인정보 처리방침"
            )
        }
        
        self.navigationController.pushViewController(mypageWebviewVC, animated: true)
    }
}
