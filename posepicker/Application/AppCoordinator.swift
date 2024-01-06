//
//  AppCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

protocol Coordinator {
    var childCoordinators : [Coordinator] { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    static var loginState: Bool {
        if let _ = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.KeychainKeyParameters.refreshToken) {
            return true
        }
        return false
    }
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() { }
}
