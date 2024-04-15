//
//  EmptyBookmarkView.swift
//  posepicker
//
//  Created by Jun on 2023/10/26.
//

import UIKit

class EmptyBookmarkView: UIView {
    
    // MARK: - Subviews
    
    let mainLabel = UILabel()
        .then {
            $0.textColor = .textSecondary
            $0.font = .h4
            $0.text = "포즈를 보관해 보세요!"
        }
    
    let subLabel = UILabel()
        .then {
            $0.textColor = .textTertiary
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.numberOfLines = 0
            $0.text = "북마크 버튼으로 포즈를 보관할 수 있어요.\n포즈피드에서 멋진 포즈를 찾아 보관해보세요."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: $0.text ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            $0.attributedText = attrString
        }
    
    let toPoseFeedButton = UIButton(type: .system)
        .then {
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle("포즈피드 바로가기", for: .normal)
            $0.backgroundColor = .bgSubWhite
            $0.tintColor = .textSecondary
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

    // MARK: - Functions
    func render() {
        self.addSubViews([mainLabel, subLabel, toPoseFeedButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        toPoseFeedButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(52)
        }
    }
    
    func bindUI() {
    }
}
