//
//  DefaultPoseTalkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

final class DefaultPoseTalkCoordinator: PoseTalkCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var recordViewController: PoseTalkViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.recordViewController = PoseTalkViewController()
    }
    
    func start() {
        let poseTalkViewController = PoseTalkViewController()
        poseTalkViewController.viewModel = PoseTalkViewModel(
            posetalkUseCase: DefaultPoseTalkUseCase(
                posetalkRepository: DefaultPoseTalkRepository(
                    networkService: DefaultNetworkService())
            ))
        
        self.navigationController.pushViewController(poseTalkViewController, animated: true)
    }
}

extension DefaultPoseTalkCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
