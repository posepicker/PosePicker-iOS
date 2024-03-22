//
//  CoordinatorFinishDelegate.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import Foundation

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}
