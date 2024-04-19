//
//  ToolTip.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/02.
//

import UIKit
import RxSwift

/// 툴팁 생성과 함께 폴리곤 위치 trailing으로 지정 필요
class ToolTip: UIView {
    
    // MARK: - Subviews
    
    let backgroundBox = UIView()
        .then {
            $0.layer.cornerRadius = 4
            $0.backgroundColor = .gray800
        }
    
    let label = UILabel()
        .then {
            $0.numberOfLines = 0
            $0.textColor = .textWhite
            $0.textAlignment = .left
            $0.font = UIScreen.main.isWiderThan375pt ? .subTitle2 : .subTitle3
            $0.text = "일명 <포즈로 말해요> 챌린지!\n제시어에 맞춰 포즈를 취해 보세요."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = UIScreen.main.isWiderThan375pt ? 22 : 18
            paragraphStyle.alignment = .left
            let attrString = NSMutableAttributedString(string: $0.text ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            $0.attributedText = attrString
        }
    
    let closeButton = UIButton(type: .system)
        .then {
            $0.backgroundColor = .clear
            $0.setImage(ImageLiteral.imgClose12.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    
    let polygonImage = UIImageView(image: ImageLiteral.imgPolygon)
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
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
        self.addSubViews([backgroundBox, polygonImage])
        backgroundBox.addSubViews([label, closeButton])
        
        backgroundBox.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
        polygonImage.snp.makeConstraints { make in
            make.top.equalTo(backgroundBox.snp.bottom).offset(-10)
            make.width.height.equalTo(20)
            make.trailing.equalToSuperview().offset(UIScreen.main.isWiderThan375pt ? -44 : -24)
        }
        
        label.snp.makeConstraints { make in
            make.top.bottom.equalTo(backgroundBox).inset(8)
            make.leading.equalTo(backgroundBox).offset(16)
            make.trailing.equalTo(closeButton.snp.leading).offset(8)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(backgroundBox).offset(-12)
            make.top.equalTo(label)
            make.width.height.equalTo(20)
        }
    }
    
    func configUI() {
        self.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isHidden = true
            })
            .disposed(by: disposeBag)
    }

}
