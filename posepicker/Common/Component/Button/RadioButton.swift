//
//  RadioButton.swift
//  posepicker
//
//  Created by 박경준 on 3/7/24.
//

import UIKit

class RadioButton: UIButton {
    
    // MARK: - Properties
    var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                self.setImage(ImageLiteral.imgRadioSelected, for: .normal)
            } else {
                self.setImage(ImageLiteral.imgRadioDefault, for: .normal)
            }
        }
    }
    
    // MARK: - Properties
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
        self.setImage(ImageLiteral.imgRadioDefault.withRenderingMode(.alwaysOriginal), for: .normal)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .bgWhite
        configuration.imagePadding = 8
        self.configuration = configuration
        self.semanticContentAttribute = .forceLeftToRight
        self.titleLabel?.font = .paragraph
        self.setTitleColor(.textPrimary, for: .normal)
        self.setTitle(self.title, for: .normal)
        self.contentHorizontalAlignment = .leading
    }

}
