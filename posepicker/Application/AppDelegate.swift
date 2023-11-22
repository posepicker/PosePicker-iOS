//
//  AppDelegate.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKCommon
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_KEY") as? String {
            RxKakaoSDK.initSDK(appKey: kakaoKey)
        }
        
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        return false
    }
}

