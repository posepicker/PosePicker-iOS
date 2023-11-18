//
//  PoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit

class PoseFeedCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var poseFeedFilterViewController = PoseFeedFilterViewController(viewModel: PoseFeedFilterViewModel())
    
    // MARK: - Initialization
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Functions
    
    func start() { }
    
    func presentModal() {
        if let sheet = poseFeedFilterViewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 476}]
            sheet.preferredCornerRadius = 20
        }
        
        navigationController.viewControllers.first?.present(poseFeedFilterViewController, animated: true)
    }
    
    func pushDetailView(viewController: PoseDetailViewController) {
        self.navigationController.present(viewController, animated: true)
    }
    
    func dismissPoseDetailWithTagSelection(tag: String) {
        guard let posefeedViewController = self.navigationController.viewControllers.first as? PoseFeedViewController else { return }
        posefeedViewController.modalDismissWithTag.onNext(tag)
    }
}
