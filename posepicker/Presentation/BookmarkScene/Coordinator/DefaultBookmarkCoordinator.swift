//
//  DefaultBookmarkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import UIKit

final class DefaultBookmarkCoordinator: BookmarkCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var bookmarkViewController: BookMarkViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
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
}

extension DefaultBookmarkCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
