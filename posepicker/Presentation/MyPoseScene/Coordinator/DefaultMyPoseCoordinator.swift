//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

final class DefaultMyPoseCoordinator: MyPoseCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var myPoseGuidelineViewController: MyPoseGuidelineViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypose
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.myPoseGuidelineViewController = MyPoseGuidelineViewController()
    }
    
    func start() {
        myPoseGuidelineViewController.viewModel = MyPoseGuidelineViewModel(coordinator: self)
        
        myPoseGuidelineViewController.modalTransitionStyle = .crossDissolve
        myPoseGuidelineViewController.modalPresentationStyle = .overFullScreen
        
        self.navigationController.present(myPoseGuidelineViewController, animated: true)
    }
    
    func pushGuideline() {
        let webview: WebViewList = .serviceInformation
        let guidelineView = MypageWebViewController(
            urlString: webview.rawValue,
            pageTitle: "가이드라인"
        )
        
        self.navigationController.presentedViewController?.present(guidelineView, animated: true)
    }
    
    func presentImageLoadFailedPopup() {
        // 이미지를 불러오는데 실패
        let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: false)
        popupViewController.modalTransitionStyle = .crossDissolve
        popupViewController.modalPresentationStyle = .overFullScreen
        let popupView = popupViewController.popUpView as! PopUpView
        popupView.alertText.accept("이미지를 불러오는 데 실패했습니다.")
        self.navigationController.presentedViewController?.present(popupViewController, animated: true)
    }
    
    func pushMyPoseView(image: UIImage?) {
        let myposeViewController = MyPoseViewController(registeredImage: image)
        let navigationController = UINavigationController(rootViewController: myposeViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController.presentedViewController?.present(navigationController, animated: true)
    }
}
