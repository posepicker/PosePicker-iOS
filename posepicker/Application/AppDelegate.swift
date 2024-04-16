//
//  AppDelegate.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit

import SmartlookAnalytics
import FirebaseCore

import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKCommon
import RxSwift
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 캐시 한계설정
        ImageCache.default.memoryStorage.config.countLimit = 70
        ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        
        if !UserDefaults.standard.bool(forKey: "hasRunBefore") {
             // Remove Keychain items here
            KeychainManager.shared.removeAll()
             // Update the flag indicator
            UserDefaults.standard.set(true, forKey: "hasRunBefore")
        }
        
        /// 카카오 셋업
        if let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_KEY") as? String {
            RxKakaoSDK.initSDK(appKey: kakaoKey)
        }
        
        /// SmartLook 셋업
//        if let smartlookProjectKey = Bundle.main.object(forInfoDictionaryKey: "SMARTLOOK_PROJECT_KEY") as? String {
//            Smartlook.instance.preferences.projectKey = smartlookProjectKey
//            Smartlook.instance.start()
//        }
        
//        if let smartlookProjectKey = ProcessInfo.processInfo.environment["SMARTLOOK_PROJECT_KEY"] {
//            Smartlook.instance.preferences.projectKey = smartlookProjectKey
//            Smartlook.instance.start()
//        }
        
        /// Firebase 셋업
//        FirebaseApp.configure()

        
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        window.makeKeyAndVisible()
        
        self.appCoordinator = DefaultAppCoordinator(navigationController)
        self.appCoordinator?.start()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        return false
    }
}

