//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/30/24.
//

import UIKit

final class DefaultMyPoseCoordinator: MyPoseCoordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var myPoseViewController: MyPoseViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .mypose
    
    func start() {
        self.myPoseViewController.viewModel = MyPoseViewModel(
            coordinator: self,
            myPoseUseCase: DefaultMyPoseUseCase(
                myPoseRepository: DefaultMyPoseRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.navigationController.pushViewController(self.myPoseViewController, animated: true)
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.myPoseViewController = MyPoseViewController()
    }
    
    
}
