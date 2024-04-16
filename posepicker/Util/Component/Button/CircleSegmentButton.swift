//
//  CircleSegmentButton.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit

class CircleSegmentButton: UIButton {
    
    // MARK: - Properties
    var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                self.setTitleColor(.textWhite, for: .normal)
                self.backgroundColor = .mainVioletDark
            } else {
                self.setTitleColor(.violet600, for: .normal)
                self.backgroundColor = .gray100
            }
        }
    }
    
    var title: String

    // MARK: - Initialization
    required init(title: String, isCurrent: Bool = false) {
        self.title = title
        self.isCurrent = isCurrent
        super.init(frame: .zero)
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func configUI() { 
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .pretendard(.medium, ofSize: 14)
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        
        self.setTitleColor(.violet600, for: .normal)
        self.backgroundColor = .gray100
    }

}
