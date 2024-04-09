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
}

extension DefaultBookmarkCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
