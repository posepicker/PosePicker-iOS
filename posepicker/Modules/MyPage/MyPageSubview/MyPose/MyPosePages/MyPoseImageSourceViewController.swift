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
    
    let urlTextField = UITextField()
        .then {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.borderDefault.cgColor
            $0.textColor = .textPrimary
            $0.font = .subTitle2
            $0.addLeftPadding(width: 16)
            $0.placeholder = "URL 링크를 입력해 주세요."
        }
    
    let exampleLabel = UILabel()
        .then {
            $0.numberOfLines = 0
            $0.font = .subTitle2
            $0.textColor = .textBrand
            $0.textAlignment = .center
            $0.text = "아래 예시처럼 이미지와 함께 링크가 업로드!\n*개인 SNS도 가능해요"
        }
    
    let exampleImageView = UIImageView(image: ImageLiteral.imgExample)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let caption = UILabel()
        .then {
            $0.text = "예시 이미지"
            $0.font = .caption
            $0.textColor = .textTertiary
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "업로드", image: nil)
    
    // MARK: - Properties
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([mainLabel, subLabel, urlTextField, exampleImageView,exampleLabel, caption, nextButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainLabel)
            make.top.equalTo(mainLabel.snp.bottom).offset(2)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(36)
            make.height.equalTo(56)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        exampleLabel.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
        }
        
        exampleImageView.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(250).priority(.low)
            make.centerX.equalToSuperview()
            make.top.equalTo(exampleLabel.snp.bottom).offset(16).priority(.high)
        }
        
        caption.snp.makeConstraints { make in
            make.top.equalTo(exampleImageView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        urlTextField.endEditing(true)
    }
}
