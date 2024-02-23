//
//  MyPoseImageSourceViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit

class MyPoseImageSourceViewController: BaseViewController {
    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            let attributedText = NSMutableAttributedString(string: "사진 원본 출처", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "를", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.regular, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    let subLabel = UILabel()
        .then {
            $0.font = .pretendard(.regular, ofSize: 18)
            $0.textColor = .textTertiary
            let attributedText = NSMutableAttributedString(string: "올려주세요", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32), NSAttributedString.Key.foregroundColor: UIColor.textCTO])
            attributedText.append(NSAttributedString(string: " (선택)", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.regular, ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.textTertiary]))
            $0.attributedText = attributedText
        }
    
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    
    // MARK: - Initialization
    init(registeredImage: UIImage?) {
        self.registeredImage = registeredImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([mainLabel, subLabel, registeredImageView, nextButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainLabel)
            make.top.equalTo(mainLabel.snp.bottom).offset(2)
        }
        
        registeredImageView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(160)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-27)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        
    }
}
