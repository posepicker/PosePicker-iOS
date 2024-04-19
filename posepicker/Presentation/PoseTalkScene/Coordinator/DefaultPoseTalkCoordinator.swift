//
//  DefaultPoseTalkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

final class DefaultPoseTalkCoordinator: PoseTalkCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    weak var tooltipDelegate: CoordinatorTooltipDelegate?
    var navigationController: UINavigationController
    var posetalkViewController: PoseTalkViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.posetalkViewController = PoseTalkViewController()
    }
    
    func start() {
        self.posetalkViewController.viewModel = PoseTalkViewModel(
            coordinator: self,
            posetalkUseCase: DefaultPoseTalkUseCase(
                posetalkRepository: DefaultPoseTalkRepository(
                    networkService: DefaultNetworkService())
            ))
        
        self.navigationController.pushViewController(self.posetalkViewController, animated: true)
    }
    
    func toggleTooltip() {
        tooltipDelegate?.coordinatorToggleTooltip(childCoordinator: self)
    }
    
    func addTooltip() {
        tooltipDelegate?.coordinatorShowTooltip(childCoordinator: self)
    }
    
    func removeTooltip() {
        tooltipDelegate?.coordinatorHideTooltip(childCoordinator: self)
    }
}

extension DefaultPoseTalkCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
