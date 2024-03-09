//
//  UIScreen+.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit
extension UIScreen {
    /// - Mini, SE: 375.0
    /// - pro: 390.0
    /// - pro max: 428.0
    var isWiderThan375pt: Bool { self.bounds.size.width > 375 }
    var isLongerThan800pt: Bool { self.bounds.size.height > 800 }
}
