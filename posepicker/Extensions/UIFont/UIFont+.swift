//
//  UIFont+.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit

enum PretendardStyle: String {
    case black = "Pretendard-Black"
    case bold = "Pretendard-Bold"
    case extraBold = "Pretendard-ExtraBold"
    case extraLight = "Pretendard-ExtraLight"
    case light = "Pretendard-Light"
    case medium = "Pretendard-Medium"
    case regular = "Pretendard-Regular"
    case semibold = "Pretendard-SemiBold"
    case thin = "Pretendard-Thin"
}

enum LineHeight: Int {
    case h1
    case h2
    case h3
    case h4
    case subTitle1
    case subTitle2
    case subTitle3
    case paragraph
    case caption
    
    var lineHeightValue: Int {
        switch self {
        case .h1: return 60
        case .h2: return 48
        case .h3: return 36
        case .h4: return 30
        case .subTitle1: return 28
        case .subTitle2: return 22
        case .subTitle3: return 18
        case .paragraph: return 24
        case .caption: return 18
        }
    }
}

extension UIFont {
    static func pretendard(_ style: PretendardStyle, ofSize size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size)!
    }
    
    static var h1: UIFont {
        return .pretendard(.bold, ofSize: 48)
    }
    static var h2: UIFont {
        return .pretendard(.bold, ofSize: 32)
    }
    static var h3: UIFont {
        return .pretendard(.bold, ofSize: 24)
    }
    static var h4: UIFont {
        return .pretendard(.bold, ofSize: 20)
    }
    static var subTitle1: UIFont {
        return .pretendard(.medium, ofSize: 16)
    }
    static var subTitle2: UIFont {
        return .pretendard(.medium, ofSize: 14)
    }
    static var subTitle3: UIFont {
        return .pretendard(.medium, ofSize: 12)
    }
    static var paragraph: UIFont {
        return .pretendard(.regular, ofSize: 16)
    }
    static var caption: UIFont {
        return .pretendard(.medium, ofSize: 12)
    }
}
