//
//  AppDelegate.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        
        let appCoordinator = AppCoordinator(navigationController: navigationController)
        let rootCoordinator = RootCoordinator(navigationController: navigationController)
        appCoordinator.childCoordinators.append(rootCoordinator)
        appCoordinator.childCoordinators.first!.start()
        
        window.makeKeyAndVisible()
        
        return true
    }
}

