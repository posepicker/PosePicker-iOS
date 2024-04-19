//
//  CoordinatorTooltipDelegate.swift
//  posepicker
//
//  Created by 박경준 on 4/19/24.
//

import Foundation

/// 코디네이터 동작이 모두 끝났을 때 다른 뷰로 즉각 이동하기 위한 동작
protocol CoordinatorTooltipDelegate: AnyObject {
    func coordinatorToggleTooltip(childCoordinator: Coordinator)
    func coordinatorShowTooltip(childCoordinator: Coordinator)
    func coordinatorHideTooltip(childCoordinator: Coordinator)
}
