//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultPoseUploadCoordinator: PoseUploadCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var inputCompleted = BehaviorRelay<Bool>(value: false)
    var poseUploadNavigationController: UINavigationController?
    var myPoseGuidelineViewController: MyPoseGuidelineViewController
    var currentIndexFromView = BehaviorRelay<Int>(value: 0)
    var poseUploadViewController: PoseUploadViewController?
    var pageViewController: UIPageViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypose
    var controllers: [UIViewController] = []
    
    var headcount = BehaviorRelay<String>(value: "")
    var framecount = BehaviorRelay<String>(value: "")
    var tags = BehaviorRelay<String>(value: "")
    var sourceURL = BehaviorRelay<String>(value: "")
    var registeredImage = BehaviorRelay<UIImage?>(value: nil)
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
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
        self.registeredImage.accept(image)
        
        let poseUploadViewController = PoseUploadViewController(
            pageViewController: self.pageViewController,
            registeredImage: image
        )
        poseUploadViewController.viewModel = PoseUploadViewModel(
            coordinator: self
        )
        self.poseUploadViewController = poseUploadViewController
        
        self.createViewControllers(image: image)
        self.configurePageViewController(with: self.controllers)
        
        self.poseUploadNavigationController = UINavigationController(rootViewController: self.poseUploadViewController!)
        self.poseUploadNavigationController?.modalPresentationStyle = .overFullScreen
        
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.navigationController.present(
                self.poseUploadNavigationController!,
                animated: true
            )
        }
        
        
    }
    
    func presentImageExpand(origin: CGPoint, image: UIImage?) {
        let frame = CGRectMake(origin.x, origin.y, 120, 160)
        let vc = PoseUploadImageDetailViewController(registeredImage: image, frame: frame)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController.present(vc, animated: true)
    }
    
    func selectPage(_ page: PoseUploadPages) {
        let currentIndex = currentPage().pageOrderNumber()
        self.pageViewController.setViewControllers([controllers[page.pageOrderNumber()]], direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = PoseUploadPages(index: index) else {
            return
        }
        let currentIndex = currentPage().pageOrderNumber()
        self.pageViewController.setViewControllers([controllers[page.pageOrderNumber()]], direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
        self.currentIndexFromView.accept(page.pageOrderNumber())
    }
    
    func currentPage() -> PoseUploadPages {
        guard let viewController = pageViewController.viewControllers?.first as? UIViewController,
              let page = PoseUploadPages(viewController) else { return .headcount }
        
        return page
    }
    
    func viewControllerBefore() -> UIViewController? {
        let currentIndex = currentPage().pageOrderNumber()
        if currentIndex == 0 {
            return nil
        }
        return controllers[currentIndex - 1]
    }
    
    func viewControllerAfter() -> UIViewController? {
        let currentIndex = currentPage().pageOrderNumber()
        if currentIndex == controllers.count - 1 {
            return nil
        }
        
        if currentIndex == 2 && !inputCompleted.value {
            return nil
        }
        
        return controllers[currentIndex + 1]
    }
    
    func refreshDataSource() {
        self.pageViewController.dataSource = nil
        self.pageViewController.dataSource = self.poseUploadViewController
    }
    
    func observeSavePose(disposeBag: DisposeBag) -> Observable<(UIImage?, String, String, String, String)> {
        return Observable.combineLatest(
            registeredImage,
            headcount,
            framecount,
            tags,
            sourceURL
        )
    }
    
    func presentPoseSaveCompletedToast() {
        self.navigationController.dismiss(animated: true)
        guard let posefeedVC = self.navigationController.viewControllers.first as? PoseFeedViewController else { return }
        posefeedVC.poseUploadCompleteEvent.onNext(())
    }
    
    private func createViewControllers(image: UIImage?) {
        let poseUploadHeadcountVC = PoseUploadHeadcountViewController(registeredImage: image)
        poseUploadHeadcountVC.viewModel = PoseUploadHeadcountViewModel(coordinator: self)
        
        let poseUploadFramecountVC = PoseUploadFramecountViewController(registeredImage: image)
        poseUploadFramecountVC.viewModel = PoseUploadFramecountViewModel(coordinator: self)
        
        let poseUploadTagVC = PoseUploadTagViewController(registeredImage: image)
        poseUploadTagVC.viewModel = PoseUploadTagViewModel(coordinator: self)
        
        let poseUploadImageSourceVC = PoseUploadImageSourceViewController()
        poseUploadImageSourceVC.viewModel = PoseUploadImageSourceViewModel(
            coordinator: self,
            poseUploadUseCase: DefaultPoseUploadUseCase(
                poseUploadRepository: DefaultPoseUploadRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.controllers = [
            poseUploadHeadcountVC,
            poseUploadFramecountVC,
            poseUploadTagVC,
            poseUploadImageSourceVC
        ]
    }
    
    private func configurePageViewController(with pageViewControllers: [UIViewController]) {
        guard let poseUploadViewController = self.poseUploadViewController else { return }
        self.pageViewController.delegate = poseUploadViewController
        self.pageViewController.dataSource = poseUploadViewController
        self.pageViewController.setViewControllers([pageViewControllers[0]], direction: .forward, animated: true)
        self.poseUploadNavigationController?.pushViewController(poseUploadViewController, animated: true)
    }
}
