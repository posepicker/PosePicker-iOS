//
//  DefaultBookmarkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import UIKit

final class DefaultBookmarkCoordinator: BookmarkCoordinator {
    weak var loginDelegate: CoordinatorLoginDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    weak var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate?
    
    var navigationController: UINavigationController
    var bookmarkViewController: BookMarkViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .bookmark
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.bookmarkViewController = BookMarkViewController()
    }
    
    func start() {
        bookmarkViewController.viewModel = BookmarkViewModel(
            coordinator: self,
            bookmarkUseCase: DefaultBookmarkUseCase(
                bookmarkRepository: DefaultBookmarkRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        self.navigationController.pushViewController(self.bookmarkViewController, animated: true)
    }
    
    func presentBookmarkDetail(viewModel: BookmarkFeedCellViewModel) {
        let bookmarkDetailViewController = BookmarkDetailViewController()
        bookmarkDetailViewController.viewModel = BookmarkDetailViewModel(
            coordinator: self,
            poseDetailUseCase: DefaultPoseDetailUseCase(
                poseDetailRepository: DefaultPoseDetailRepository(
                    networkService: DefaultNetworkService()
                ),
                poseId: viewModel.poseId.value
            ),
            bindViewModel: viewModel
        )
        self.navigationController.present(bookmarkDetailViewController, animated: true)
    }
    
    func presentClipboardCompleted(poseId: Int) {
        let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: false)
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        let popupView = popupVC.popUpView as! PopUpView
        popupView.alertText.accept("링크가 복사되었습니다.")
        self.navigationController.presentedViewController?.present(popupVC, animated: true)
    }
    
    func moveToExternalApp(url: URL) {
        UIApplication.shared.open(url)
    }

    func dismissPoseDetail(tag: String) {
        self.navigationController.dismiss(animated: true)
        bookmarkBindingDelegate?.coordinatorBookmarkSetAndDismissed(
            childCoordinator: self,
            tag: tag
        )
        self.navigationController.popViewController(animated: true)
    }
}
