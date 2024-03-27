//
//  Pages.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import Foundation

enum PageViewType: String, CaseIterable {
    case posepick
    case posetalk
    case posefeed
    case bookmark
    case myPage
    
    init?(index: Int) {
        switch index {
        case 0: self = .posepick
        case 1: self = .posetalk
        case 2: self = .posefeed
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
