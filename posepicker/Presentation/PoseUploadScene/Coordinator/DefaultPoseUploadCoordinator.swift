//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

final class DefaultPoseUploadCoordinator: PoseUploadCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var myPoseGuidelineViewController: MyPoseGuidelineViewController
    var poseUploadViewController: PoseUploadViewController?
    var pageViewController: UIPageViewController?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypose
    var controllers: [UINavigationController] = []
    
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
    
    func pushPoseUploadView(image: UIImage?) {
        let poseUploadViewController = PoseUploadViewController(registeredImage: image)
        poseUploadViewController.viewModel = PoseUploadViewModel(coordinator: self)
        
        self.pageViewController = poseUploadViewController.pageViewController
        
        let navigationController = UINavigationController(rootViewController: poseUploadViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController.presentedViewController?.present(navigationController, animated: true)
    }
    
    func selectPage(_ page: PageViewType) {
        <#code#>
    }
    
    func setSelectedIndex(_ index: Int) {
        <#code#>
    }
    
    func currentPage() -> PageViewType? {
        <#code#>
    }
    
    func viewControllerBefore() -> UIViewController? {
        <#code#>
    }
    
    func viewControllerAfter() -> UIViewController? {
        <#code#>
    }
    
    private func createViewControllers() {
        let pages: [PageViewType] = [.posepick, .posetalk, .posefeed]
        controllers = pages.map({
            self.createPageViewNavigationController(of: $0)
        })
        self.configurePageViewController(with: controllers)
    }
    
    private func configurePageViewController(with pageViewControllers: [UIViewController]) {
        guard let poseUploadViewController = self.poseUploadViewController else { return }
        self.pageViewController?.delegate = poseUploadViewController
        self.pageViewController?.dataSource = poseUploadViewController
        self.pageViewController?.setViewControllers([pageViewControllers[0]], direction: .forward, animated: true)
        self.navigationController.pushViewController(poseUploadViewController, animated: true)
    }
    
    private func startPageViewCoordinator(of page: PageViewType, to pageviewNavigationController: UINavigationController) {
        switch page {
        case .posepick:
            self.navigationController.push
            let posepickCoordinator = DefaultPosePickCoordinator(pageviewNavigationController)
            posepickCoordinator.finishDelegate = self
            self.childCoordinators.append(posepickCoordinator)
            posepickCoordinator.start()
        case .posetalk:
            let posetalkCoordinator = DefaultPoseTalkCoordinator(pageviewNavigationController)
            posetalkCoordinator.finishDelegate = self
            self.childCoordinators.append(posetalkCoordinator)
            posetalkCoordinator.start()
        case .posefeed:
            let posefeedCoordinator = DefaultPoseFeedCoordinator(pageviewNavigationController)
            posefeedCoordinator.loginDelegate = self
            self.childCoordinators.append(posefeedCoordinator)
            posefeedCoordinator.start()
        default:
            break
        }
    }
}
