//
//  UnderlinedLabel.swift
//  posepicker
//
//  Created by 박경준 on 7/11/24.
//

import UIKit

class UnderlinedLabel: UILabel {
    var underlinedText: String? {
        didSet {
            guard let underlinedText = underlinedText,
                  let text = text else { return }
            let textRange = NSRange(location: 0, length: underlinedText.count)
            let startIndex = text.index(text.startIndex, offsetBy: underlinedText.count)
            let newAttributedText = NSMutableAttributedString(string: underlinedText + text[startIndex...])
            
            if let attributedText {
                attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attributes, range, _ in
                    newAttributedText.addAttributes(attributes, range: range)
                }
            }
            newAttributedText.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: textRange)
            self.attributedText = newAttributedText
        }
    }
}
