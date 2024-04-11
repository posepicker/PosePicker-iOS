//
//  PoseUploadPages.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit

enum PoseUploadPages: String, CaseIterable {
    case headcount
    case framecount
    case tags
    case imageSource
    
    init?(index: Int) {
        switch index {
        case 0: self = .headcount
        case 1: self = .framecount
        case 2: self = .tags
        case 3: self = .imageSource
        default: return nil
        }
    }
    
    init?(_ viewController: UIViewController) {
        switch viewController {
        case viewController as? PoseUploadHeadcountViewController: self = .headcount
        case viewController as? PoseUploadFramecountViewController: self = .framecount
        case viewController as? PoseUploadTagViewController: self = .tags
        case viewController as? PoseUploadImageSourceViewController: self = .imageSource
        default: return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .headcount:
            return 0
        case .framecount:
            return 1
        case .tags:
            return 2
        case .imageSource:
            return 3
        }
    }
}
