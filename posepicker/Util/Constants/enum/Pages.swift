//
//  Pages.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import UIKit

enum PageViewType: String, CaseIterable {
    case posepick
    case posetalk
    case posefeed
    case mypose
    case bookmark
    case myPage
    
    init?(index: Int) {
        switch index {
        case 0: self = .posepick
        case 1: self = .posetalk
        case 2: self = .posefeed
        case 3: self = .mypose
        default: return nil
        }
    }
    
    init?(_ viewController: UIViewController) {
        switch viewController {
        case viewController as? PosePickViewController: self = .posepick
        case viewController as? PoseTalkViewController: self = .posetalk
        case viewController as? PoseFeedViewController: self = .posefeed
        case viewController as? MyPoseViewController: self = .mypose
        default: return nil
        }
    }
    
    func pageTitleValue() -> String {
        switch self {
        case .posepick:
            return "포즈픽"
        case .posetalk:
            return "포즈톡"
        case .posefeed:
            return "포즈피드"
        case .mypose:
            return "마이포즈"
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
        case .mypose:
            return 3
        case .bookmark:
            return 4
        case .myPage:
            return 5
        }
    }
}
