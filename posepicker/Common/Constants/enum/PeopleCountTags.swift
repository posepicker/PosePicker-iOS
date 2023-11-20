//
//  FrameCountTags.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/20.
//

import Foundation

enum PeopleCountTags: String {
    case all = "전체"
    case one = "1인"
    case two = "2인"
    case three = "3인"
    case four = "4인"
    case moreThanFive = "5인+"
    
    static func getAllFrameCountTags() -> [PeopleCountTags] {
        return [.all, .one, .two, .three, .four, .moreThanFive]
    }
    
    static func getTagFromTitle(title: String) -> PeopleCountTags? {
        switch title {
        case "전체": return .all
        case "1인": return .one
        case "2인": return .two
        case "3인": return .three
        case "4인": return .four
        case "5인+": return .moreThanFive
        default: return nil
        }
    }
    
    static func getNumberFromPeopleCountString(countString: String) -> Int? {
        switch countString {
        case "전체":
            return 0
        case "1인":
            return 1
        case "2인":
            return 2
        case "3인":
            return 3
        case "4인":
            return 4
        case "5인+":
            return 5
        default:
            return nil
        }
    }
}
