//
//  UITextField+.swift
//  posepicker
//
//  Created by 박경준 on 2/29/24.
//

import UIKit

extension UITextField {
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
