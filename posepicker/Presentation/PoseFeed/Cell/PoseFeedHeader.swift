//
//  PoseFeedHeader.swift
//  posepicker
//
//  Created by Jun on 2023/11/14.
//

import UIKit

class PoseFeedHeader: UICollectionReusableView {
    
    let label = UILabel()
        .then {
            $0.textAlignment = .left
            $0.textColor = .textPrimary
            $0.font = .h4
            $0.text = "이런 포즈는 어때요?"
        }

    // MARK: - Properties
    static let identifier = "PoseFeedHeader"
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func render() {
        self.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    func configureHeader(with title: String) {
        label.text = title
    }
}
