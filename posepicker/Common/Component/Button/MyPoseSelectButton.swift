//
//  MyPoseSelectButton.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit

class MyPoseSelectButton: UIButton {
    
    // MARK: - Properties
    var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                self.setTitleColor(.mainVioletDark, for: .normal)
                self.backgroundColor = .violet100
                self.layer.borderColor = UIColor.mainViolet.cgColor
                self.titleLabel?.font = .pretendard(.bold, ofSize: 18)
            } else {
                self.setTitleColor(.textSecondary, for: .normal)
                self.backgroundColor = .init(hex: "#F7F7FA")
                self.layer.borderColor = UIColor.borderDefault.cgColor
                self.titleLabel?.font = .pretendard(.medium, ofSize: 18)
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
        self.titleLabel?.font = .pretendard(.medium, ofSize: 18)
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        self.setTitleColor(.textSecondary, for: .normal)
        self.backgroundColor = .init(hex: "#F7F7FA")
        self.layer.borderColor = UIColor.borderDefault.cgColor
        self.layer.borderWidth = 1
    }
}
