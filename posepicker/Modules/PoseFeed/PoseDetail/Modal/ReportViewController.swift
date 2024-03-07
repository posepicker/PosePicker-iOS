//
//  ReportViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/7/24.
//

import UIKit

import RxSwift
import RxCocoa

class ReportViewController: BaseViewController {
    
    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            $0.numberOfLines = 0
            let attributedText = NSMutableAttributedString(string: "신고하는 ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary, NSAttributedString.Key.font: UIFont.h3])
            attributedText.append(NSAttributedString(string: "이유", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainVioletDark, NSAttributedString.Key.font: UIFont.h3]))
            attributedText.append(NSAttributedString(string: "가\n무엇인가요?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary, NSAttributedString.Key.font: UIFont.h3]))
            
            // 행간
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 36
            paragraphStyle.alignment = .center
            attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
            
            $0.attributedText = attributedText
        }
    
    let closeButton = UIBarButtonItem(image: ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault), style: .plain, target: self, action: #selector(closeButtonTapped))
    
    lazy var buttonGroupStackView = UIStackView(arrangedSubviews: self.radioGroup)
        .then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .leading
        }
    
    // MARK: - Properties
    
    let radioGroup: [RadioButton] = [
        RadioButton(title: "스팸 또는 중복 콘텐츠"),
        RadioButton(title: "폭력적 또는 선정적 콘텐츠"),
        RadioButton(title: "초상권 등 기타 법적 문제 침해"),
        RadioButton(title: "기타 입력"),
    ]
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([mainLabel, buttonGroupStackView])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            make.centerX.equalToSuperview()
        }
        
        buttonGroupStackView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(224)
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
        self.navigationItem.leftBarButtonItem = closeButton
        
        radioGroup.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            button.rx.tap.asDriver()
                .drive(onNext: {
                    self.resetButtonUI()
                    button.isCurrent = true
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func resetButtonUI(){
        radioGroup.forEach { $0.isCurrent = false }
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }

}
