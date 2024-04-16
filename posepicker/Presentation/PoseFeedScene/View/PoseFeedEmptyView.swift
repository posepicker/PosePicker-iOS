//
//  PoseFeedEmptyView.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/13.
//

import UIKit

import RxSwift

class PoseFeedEmptyView: UICollectionReusableView {
    
    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            $0.textAlignment = .center
            $0.textColor = .textSecondary
            $0.font = .h4
            $0.text = "신비한 포즈를 찾으시는군요!"
        }
    
    let subLabel = UILabel()
        .then {
            $0.textAlignment = .center
            $0.textColor = .textTertiary
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.text = "포즈를 직접 업로드 해보세요."
        }
    
    let linkButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "문의사항 남기기", image: nil)
        .then {
            $0.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    
    // MARK: - Properties
    static let identifier = "PoseFeedEmptyView"

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func render() {
        self.addSubViews([mainLabel, subLabel, linkButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(80)
            make.centerX.equalTo(self)
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(8)
            make.centerX.equalTo(self)
        }
        
        linkButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(32)
            make.height.equalTo(52)
            make.width.equalTo(142)
            make.centerX.equalTo(self)
        }
    }
    
    func configUI() {
        
    }
    
    // MARK: - Objc Functions
    @objc
    func linkButtonTapped() {
        if let url = URL(string: "https://litt.ly/posepicker") {
            UIApplication.shared.open(url)
        }
    }
}
