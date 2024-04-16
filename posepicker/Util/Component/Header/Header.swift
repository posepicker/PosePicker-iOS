//
//  Header.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import UIKit

class Header: UIView {
    
    // MARK: - Subviews
    let appTitleLabel = UILabel()
        .then {
            $0.textColor = .textPrimary
            $0.font = .h4
            $0.text = "PosePicker"
        }
    
    let menuButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgMenu24.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    
    let bookMarkButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgBookmarkFill24.withTintColor(.iconDefault).withRenderingMode(.alwaysOriginal), for: .normal)
        }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
        bindUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var isNavigating = false
    
    // MARK: - Functions
    
    func render() {
        self.addSubViews([appTitleLabel, menuButton, bookMarkButton])
        
        appTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        
        bookMarkButton.snp.makeConstraints { make in
            make.trailing.equalTo(menuButton.snp.leading).offset(-20)
            make.centerY.equalTo(self)
        }
    }
    
    func bindUI() {
        
    }

}
