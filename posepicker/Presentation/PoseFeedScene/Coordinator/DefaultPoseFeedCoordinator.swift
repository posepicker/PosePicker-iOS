//
//  DefaultPoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

final class DefaultPoseFeedCoordinator: PoseFeedCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var posefeedViewController: PoseFeedViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.posefeedViewController = PoseFeedViewController()
    }
    
    func start() {
//        self.posetalkViewController.viewModel = PoseFeedViewModel(
//            posetalkUseCase: DefaultPoseTalkUseCase(
//                posetalkRepository: DefaultPoseTalkRepository(
//                    networkService: DefaultNetworkService())
//            ))
        
        self.navigationController.pushViewController(self.posefeedViewController, animated: true)
    }
    
}
