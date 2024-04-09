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
    
}

extension DefaultMyPageCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
