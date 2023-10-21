//
//  RootCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

enum RootPage {
    case posepick
    case posetok
    case posefeed
    case bookmark
    case myPage
    
    func pageTitleValue() -> String {
        switch self {
        case .posepick:
            return "포즈픽"
        case .posetok:
            return "포즈톡"
        case .posefeed:
            return "포즈피드"
        case .bookmark:
            return "북마크"
        case .myPage:
            return ""
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .posepick:
            return 0
        case .posetok:
            return 1
        case .posefeed:
            return 2
        case .bookmark:
            return 3
        case .myPage:
            return 4
        }
    }
}

class RootCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Initialization
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Functions
    
    func start() {
        navigationController.viewControllers = [RootViewController()]
    }
    
}
