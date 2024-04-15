//
//  DefaultPosePickCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

final class DefaultPosePickCoordinator: PosePickCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var posepickViewController: PosePickViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posepick
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.posepickViewController = PosePickViewController()
    }
    
    func start() {
        self.posepickViewController.viewModel = PosePickViewModel(
            coordinator: self,
            posepickUseCase: DefaultPosePickUseCase(
                posepickRepository: DefaultPosePickRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.navigationController.pushViewController(self.posepickViewController, animated: true)
    }
    
    func presentDetailImage(retrievedImage: UIImage?) {
        let vc = ImagePopUpViewController(mainImage: retrievedImage)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController.present(vc, animated: true)
    }
}

extension DefaultPosePickCoordinator {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter({ $0.type != childCoordinator.type })
        childCoordinator.navigationController.popToRootViewController(animated: true)
    }
}
