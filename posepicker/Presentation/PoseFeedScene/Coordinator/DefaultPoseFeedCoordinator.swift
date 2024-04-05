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
        self.posefeedViewController.viewModel = PoseFeedViewModel(
            coordinator: self,
            posefeedUseCase: DefaultPoseFeedUseCase(
                posefeedRepository: DefaultPoseFeedRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.navigationController.pushViewController(self.posefeedViewController, animated: true)
    }
    
    func presentFilterModal() {
        let posefeedFilterViewController = PoseFeedFilterViewController()
        
        posefeedFilterViewController.viewModel = PoseFeedFilterViewModel(
            coordinator: self,
            posefeedFilterUseCase: DefaultPoseFeedFilterUseCase()
        )
        
        if let sheet = posefeedFilterViewController.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 476 })]
            sheet.preferredCornerRadius = 20
        }
        
        self.navigationController.present(posefeedFilterViewController, animated: true)
    }
    
}
