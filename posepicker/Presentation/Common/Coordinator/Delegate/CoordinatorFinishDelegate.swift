//
//  CoordinatorFinishDelegate.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import Foundation

/// 코디네이터 동작이 모두 끝났을 때 다른 뷰로 즉각 이동하기 위한 동작
protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}
