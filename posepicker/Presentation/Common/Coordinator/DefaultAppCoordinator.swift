//
//  AppCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class DefaultAppCoordinator: AppCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType { .app }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
    }
    
    func showPageviewFlow() {
        
    }
    
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0.type != childCoordinator.type })
        
        self.navigationController.view.backgroundColor = .systemBackground
        self.navigationController.viewControllers.removeAll()
        
//        switch childCoordinator.type {
//        case .tab:
//            self.showLoginFlow()
//        case .login:
//            self.showTabBarFlow()
//        default:
//            break
//        }
    }
}
