//
//  MockPoseUploadCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/10/24.
//

import UIKit
import RxSwift
import RxRelay

@testable import posepicker

final class MockPoseUploadCoordinator: PoseUploadCoordinator {
    var pageViewController: UIPageViewController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var inputCompleted = BehaviorRelay<Bool>(value: false)
    
    var currentIndexFromView = BehaviorRelay<Int>(value: 0)
    var controllers: [UIViewController] = []
    var poseUploadViewController: PoseUploadViewController?
    var poseUploadNavigationController: UINavigationController?
    
    func pushGuideline() {
        print(#function)
    }
    
    func presentImageLoadFailedPopup() {
        print(#function)
    }
    
    func pushPoseUploadView(image: UIImage?) {
        print(#function)
    }
    
    func presentImageExpand(origin: CGPoint, image: UIImage?) {
        print(#function)
    }
    
    var headcount = BehaviorRelay<String>(value: "")
    
    var framecount = BehaviorRelay<String>(value: "")
    
    var tags = BehaviorRelay<String>(value: "")
    
    var sourceURL = BehaviorRelay<String>(value: "")
    
    var registeredImage = BehaviorRelay<UIImage?>(value: nil)
    
    func selectPage(_ page: posepicker.PoseUploadPages) {
        print(#function)
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = PoseUploadPages(index: index)  else { return }
        let currentIndex = currentPage().pageOrderNumber()
        self.pageViewController.setViewControllers([controllers[page.pageOrderNumber()]], direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
        self.currentIndexFromView.accept(page.pageOrderNumber())
    }
    
    func currentPage() -> PoseUploadPages {
        guard let navigationController = pageViewController.viewControllers?.first as? UINavigationController,
              let viewController = navigationController.viewControllers.first,
              let page = PoseUploadPages(viewController) else { return .headcount }
        
        return page
    }
    
    func viewControllerBefore() -> UIViewController? {
        print(#function)
        return nil
    }
    
    func viewControllerAfter() -> UIViewController? {
        print(#function)
        return nil
        
    }
    
    func refreshDataSource() {
        print(#function)
    }

    func observeSavePose(disposeBag: DisposeBag) -> Observable<(UIImage?, String, String, String, String)> {
        return .just((nil, "1명", "1컷", "친구,가족,재미", "https://url.com"))
    }
    
    func presentPoseSaveCompletedToast() {
        print(#function)
    }
    
    var finishDelegate: (any posepicker.CoordinatorFinishDelegate)?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [any posepicker.Coordinator] = []
    
    var type: posepicker.CoordinatorType = .mypose
    
    func start() {
        print(#function)
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.createViewControllers(image: nil)
        self.configurePageViewController(with: self.controllers)
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
