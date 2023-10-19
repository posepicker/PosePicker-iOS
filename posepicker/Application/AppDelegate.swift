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
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        
        window.makeKeyAndVisible()
        return true
    }
}

