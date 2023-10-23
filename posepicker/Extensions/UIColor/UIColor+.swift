//
//  UIColor+.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit

extension UIColor {
    static var bgWhite: UIColor {
        return .init(hex: "#FFFFFF")
    }
    static var textWhite: UIColor {
        return .init(hex: "#FFFFFF")
    }
    static var iconWhite: UIColor {
        return .init(hex: "#FFFFFF")
    }
    static var bgCardUI: UIColor {
        return .init(hex: "#F9F9FB")
    }
    static var bgSubWhite: UIColor {
        return .init(hex: "#F7F7FA")
    }
    static var bgDivider: UIColor {
        return .init(hex: "#F0F0F5")
    }
    static var borderDisabled: UIColor {
        return .init(hex: "#F0F0F5")
    }
    static var borderDefault: UIColor {
        return .init(hex: "#E1E1E8")
    }
    static var textCaption: UIColor {
        return .init(hex: "#CDCED6")
    }
    static var textTertiary: UIColor {
        return .init(hex: "#A9ABB8")
    }
    static var iconDisabled: UIColor {
        return .init(hex: "#A9ABB8")
    }
    static var iconHover: UIColor {
        return .init(hex: "#858899")
    }
    static var textSecondary: UIColor {
        return .init(hex: "#525463")
    }
    static var iconDefault: UIColor {
        return .init(hex: "#3E404C")
    }
    static var textPrimary: UIColor {
        return .init(hex: "#2B2D36")
    }
    static var borderActive: UIColor {
        return .init(hex: "#2B2D36")
    }
    static var textCTO: UIColor {
        return .init(hex: "#141218")
    }
    static var textBrand: UIColor {
        return .init(hex: "#8662F3")
    }
    static var mainVioletLight: UIColor {
        return .init(hex: "#B29BF8")
    }
    static var mainViolet: UIColor {
        return .init(hex: "#744CEB")
    }
    static var mainVioletDark: UIColor {
        return .init(hex: "#5B2EE0")
    }
    
    // violet brand color
    static var violet050: UIColor {
        return .init(hex: "#F4F1FE")
    }
    static var violet100: UIColor {
        return .init(hex: "#E2D9FC")
    }
    static var violet200: UIColor {
        return .init(hex: "#C8B8FA")
    }
    static var violet300: UIColor {
        return .init(hex: "#B29BF8")
    }
    static var violet400: UIColor {
        return .init(hex: "#9C7FF5")
    }
    static var violet600: UIColor {
        return .init(hex: "#744CEB")
    }
    static var violet700: UIColor {
        return .init(hex: "#5B2EE0")
    }
    static var violet800: UIColor {
        return .init(hex: "#4B25C1")
    }
    static var violet900: UIColor {
        return .init(hex: "#412499")
    }
    static var violet950: UIColor {
        return .init(hex: "#21005D")
    }
    static var appBlack: UIColor {
        return .init(hex: "#141218")
    }
    
    // gray variation
    static var gray200: UIColor {
        return .init(hex: "#E8E8EE")
    }
    static var gray950: UIColor {
        return .init(hex: "#252730")
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
