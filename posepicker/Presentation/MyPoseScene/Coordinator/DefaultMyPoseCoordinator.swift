//
//  DefaultMyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

final class DefaultMyPoseCoordinator: MyPoseCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var bookmarkViewController: BookMarkViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .bookmark
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.bookmarkViewController = BookMarkViewController()
    }
    
    func start() {
        let myposeViewController = MyPoseViewController(registeredImage: nil)
    }
}
