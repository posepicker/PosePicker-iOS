//
//  RootCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

enum RootPage {
    case posepick
    case posetalk
    case posefeed
    case bookmark
    case myPage
    
    func pageTitleValue() -> String {
        switch self {
        case .posepick:
            return "포즈픽"
        case .posetalk:
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
        case .posetalk:
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
    
    func start() { /// 화면 전환에 대한 실질적인 로직들이 전부 뷰컨 내에 내장되는데.. 불필요한 코디네이터 패턴이 된듯
        navigationController.viewControllers = [RootViewController()]
    }
}
