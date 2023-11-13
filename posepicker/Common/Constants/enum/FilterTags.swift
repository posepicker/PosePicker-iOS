//
//  FilterTags.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/27.
//

import Foundation

enum FilterTags: String {
    case solo = "단독"
    case friend = "친구"
    case couple = "커플"
    case family = "가족"
    case coworker = "동료"
    case celebrity = "유명프레임"
    case character = "캐릭터"
    case trend = "유행"
    case fun = "재미"
    case natural = "자연스러움"
    
    static func getAllFilterTags() -> [FilterTags] {
        return [.solo, .friend, .couple, .family, .coworker, .celebrity, .character, .trend, .fun, .natural]
    }
    
    static func getTagFromTitle(title: String) -> FilterTags? {
        switch title {
        case "단독": return .solo
        case "친구": return .friend
        case "커플": return .couple
        case "가족": return .family
        case "동료": return .coworker
        case "유명프레임": return .celebrity
        case "캐릭터": return .character
        case "유행": return .trend
        case "재미": return .fun
        case "자연스러움": return .natural
        default: return nil
        }
    }
    
    static func getNumberFromPeopleCountString(countString: String) -> Int {
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
            return 0
        }
    }
    
    static func getNumberFromFrameCountString(countString: String) -> Int {
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
        case "8컷+":
            return 8
        default:
            return 0
        }
    }
    
    func getTagNumber() -> Int {
        switch self {
        case .solo: return 0
        case .friend: return 1
        case .couple: return 2
        case .family: return 3
        case .coworker: return 4
        case .celebrity: return 5
        case .character: return 6
        case .trend: return 7
        case .fun: return 8
        case .natural: return 9
        }
    }
}
