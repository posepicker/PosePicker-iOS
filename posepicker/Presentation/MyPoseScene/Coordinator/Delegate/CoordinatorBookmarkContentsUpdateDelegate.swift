//
//  CoordinatorBookmarkContentsUpdateDelegate.swift
//  posepicker
//
//  Created by 박경준 on 5/9/24.
//

import Foundation

protocol CoordinatorBookmarkContentsUpdateDelegate: AnyObject {
    func coordinatorBookmarkContentsUpdated(childCoordinator: Coordinator)
    func coordinatorPoseCountsUpdated(childCoordinator: Coordinator)
}
