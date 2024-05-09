//
//  CoordinatorPageMoveDelegate.swift
//  posepicker
//
//  Created by 박경준 on 5/9/24.
//

import Foundation

protocol CoordinatorPageMoveDelegate: AnyObject {
    func coordinatorMoveTo(pageType: PageViewType)
}
