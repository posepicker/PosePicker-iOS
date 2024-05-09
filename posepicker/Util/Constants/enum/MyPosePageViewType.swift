//
//  MyPosePageViewType.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit

enum MyPosePageViewType: String, CaseIterable {
    case uploaded
    case saved
    
    init?(index: Int) {
        switch index {
        case 0: self = .uploaded
        case 1: self = .saved
        default: return nil
        }
    }
    
    init?(_ viewController: UIViewController) {
        switch viewController {
        case viewController as? MyPoseUploadedViewController: self = .uploaded
        case viewController as? MyPoseSavedViewController: self = .saved
        default: return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .uploaded:
            return 0
        case .saved:
            return 1
        }
    }
}
