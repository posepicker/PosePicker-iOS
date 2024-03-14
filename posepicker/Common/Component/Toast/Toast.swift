//
//  Toast.swift
//  posepicker
//
//  Created by 박경준 on 3/14/24.
//

import UIKit

class Toast: UIView {

    // MARK: - Subviews
    lazy var label = UILabel()
        .then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = self.title
            $0.font = .subTitle2
            $0.textColor = .textWhite
        }
    
    // MARK: - Properties
    let title: String
    
    // MARK: - Initialization
    required init(title: String) {
        self.title = title
        super.init(frame: .zero)
        render()
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func render() {
        self.addSubViews([label])
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configUI() {
        self.backgroundColor = .dimmed70
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
}
