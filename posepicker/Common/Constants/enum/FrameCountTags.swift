//
//  FrameCountTags.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/20.
//

import Foundation

enum FrameCountTags: String {
    case allCut = "전체"
    case oneCut = "1컷"
    case threeCut = "3컷"
    case fourCut = "4컷"
    case sixCut = "6컷"
    case moreThanEight = "8컷+"
    
    static func getAllFrameCountTags() -> [FrameCountTags] {
        return [.allCut, .oneCut, .threeCut, .fourCut, .sixCut, .moreThanEight]
    }
    
    static func getTagFromTitle(title: String) -> FrameCountTags? {
        switch title {
        case "전체": return .allCut
        case "1컷": return .oneCut
        case "3컷": return .threeCut
        case "4컷": return .fourCut
        case "6컷": return .sixCut
        case "8컷+": return .moreThanEight
        default: return nil
        }
    }
    
    static func getNumberFromFrameCountString(countString: String) -> Int? {
        switch countString {
        case "전체":
            return 0
        case "1컷":
            return 1
        case "3컷":
            return 3
        case "4컷":
            return 4
        case "6컷":
            return 6
        case "7컷+":
            return 8
        default:
            return nil
        }
    }
}
