//
//  CoordinatorBookmarkBindingDelegate.swift
//  posepicker
//
//  Created by 박경준 on 4/9/24.
//

import Foundation

protocol CoordinatorBookmarkBindingDelegate: AnyObject {
    func coordinatorBookmarkModified(childCoordinator: Coordinator, poseId: Int)
    
    func coordinatorBookmarkSetAndDismissed(childCoordinator: Coordinator, tag: String)
}
