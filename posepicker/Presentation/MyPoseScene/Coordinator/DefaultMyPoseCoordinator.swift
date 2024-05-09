//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/30/24.
//

import UIKit

final class DefaultMyPoseCoordinator: MyPoseCoordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate?
    
    var navigationController: UINavigationController
    var myPoseViewController: MyPoseViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypose
    var pageViewController: UIPageViewController
    
    var controllers: [UIViewController] = []
    
    func start() {
        self.myPoseViewController.viewModel = MyPoseViewModel(
            coordinator: self,
            myPoseUseCase: DefaultMyPoseUseCase(
                myPoseRepository: DefaultMyPoseRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.navigationController.pushViewController(self.myPoseViewController, animated: true)
        
        self.createViewControllers()
        self.configurePageViewController(with: controllers)
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.myPoseViewController = MyPoseViewController(pageViewController: self.pageViewController)
    }
    
    func currentPage() -> MyPosePageViewType? {
        guard let viewController = pageViewController.viewControllers?.first as? UIViewController,
              let page = MyPosePageViewType(viewController) else { return .uploaded }

        return page
    }
    
    func presentBookmarkDetail(viewModel: BookmarkFeedCellViewModel) {
        let bookmarkDetailViewController = BookmarkDetailViewController()
        bookmarkDetailViewController.viewModel = BookmarkDetailViewModel(
            coordinator: nil,
            poseDetailUseCase: DefaultPoseDetailUseCase(
                poseDetailRepository: DefaultPoseDetailRepository(
                    networkService: DefaultNetworkService()
                ),
                poseId: viewModel.poseId.value
            ),
            bindViewModel: viewModel
        )
        self.pageViewController.present(bookmarkDetailViewController, animated: true)
    }
    
    func presentClipboardCompleted(poseId: Int) {
        
    }
    
    func moveToExternalApp(url: URL) {
        
    }
    
    func dismissPoseDetail(tag: String) {
        
    }
    
    func viewControllerBefore() -> UIViewController? {
        guard let currentIndex = currentPage()?.pageOrderNumber() else { return nil }
        if currentIndex == 0 {
            return nil
        }
        
        return controllers[currentIndex - 1]
    }
    
    func viewControllerAfter() -> UIViewController? {
        guard let currentIndex = currentPage()?.pageOrderNumber() else { return nil }
        if currentIndex == controllers.count - 1 {
            return nil
        }
        return controllers[currentIndex + 1]
    }
    
    private func createViewControllers() {
        let uploadedVC = MyPoseUploadedViewController()
        
        let savedVC = MyPoseSavedViewController()
        
        savedVC.viewModel = MyPoseSavedViewModel(
            coordinator: self,
            bookmarkUseCase: DefaultBookmarkUseCase(
                bookmarkRepository: DefaultBookmarkRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.controllers = [
            uploadedVC,
            savedVC
        ]
    }
    
    private func configurePageViewController(with pageViewControllers: [UIViewController]) {
        self.pageViewController.delegate = myPoseViewController
        self.pageViewController.dataSource = myPoseViewController
        self.pageViewController.setViewControllers([pageViewControllers[0]], direction: .forward, animated: true)
    }
}

extension DefaultMyPoseCoordinator: CoordinatorBookmarkContentsUpdateDelegate {
    func coordinatorBookmarkContentsUpdated(childCoordinator: Coordinator) {
        let savedVC = self.controllers[1] as? MyPoseSavedViewController
        savedVC?.contentsUpdateEvent.onNext(())
    }
}
