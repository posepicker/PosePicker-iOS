//
//  BookmarkHeader.swift
//  posepicker
//
//  Created by 박경준 on 12/5/23.
//

import UIKit

class BookmarkEmptyView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "BookmarkHeader"
    
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
    
    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            $0.textAlignment = .center
            $0.font = .h4
            $0.textColor = .textSecondary
            $0.text = "포즈를 보관해 보세요!"
        }
    
    let subLabel = UILabel()
        .then {
            $0.textColor = .textTertiary
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.numberOfLines = 0
            $0.text = "북마크 버튼으로 포즈를 보관할 수 있어요.\n포즈피드에서 멋진 포즈를 찾아 보관해 보세요."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: $0.text ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            $0.attributedText = attrString
        }
    
    let transitionButton = UIButton(type: .system)
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .bgSubWhite
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitleColor(.textSecondary, for: .normal)
            $0.setTitle("포즈피드 바로가기", for: .normal)
        }
    
    // MARK: - Functions
    func render() {
        self.addSubViews([mainLabel, subLabel, transitionButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.centerX.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        transitionButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(52)
        }
    }
    
    func configUI() {
    }
}
