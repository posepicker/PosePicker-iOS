//
//  UserRevokeViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/15/24.
//

import UIKit

class UserRevokeViewController: BaseViewController, UIGestureRecognizerDelegate {

    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            $0.numberOfLines = 0
            let attributedText = NSMutableAttributedString(string: "떠나시는 ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary, NSAttributedString.Key.font: UIFont.h3])
            attributedText.append(NSAttributedString(string: "이유", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainVioletDark, NSAttributedString.Key.font: UIFont.h3]))
            attributedText.append(NSAttributedString(string: "를\n알려주실 수 있나요?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary, NSAttributedString.Key.font: UIFont.h3]))
            
            // 행간
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 36
            paragraphStyle.alignment = .center
            attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
            
            $0.attributedText = attributedText
        }
    
    lazy var buttonGroupStackView = UIStackView(arrangedSubviews: self.radioGroup)
        .then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .leading
        }
    
    let completeButton = PosePickButton(status: .disabled, isFill: true, position: .none, buttonTitle: "신고하기", image: nil)
    
    let textView = UITextView()
        .then {
            $0.textColor = .iconDisabled
            $0.text = "어떤 점이 당신을 떠나게 만들었나요?"
            $0.layer.borderColor = UIColor.borderDefault.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
            $0.font = .paragraph
            $0.isHidden = true
        }
    
    // MARK: - Properties
    
    let radioGroup: [RadioButton] = [
        RadioButton(title: "사용을 잘 안하게 돼요"),
        RadioButton(title: "원하는 포즈가 없어요."),
        RadioButton(title: "포즈 탐색이 어려워요."),
        RadioButton(title: "다른 서비스를 이용하고 싶어요."),
        RadioButton(title: "재가입 할 거 예요."),
        RadioButton(title: "기타 입력"),
    ]
    
    var selectedReason: String = ""
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([mainLabel, buttonGroupStackView, completeButton, textView])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(UIScreen.main.isLongerThan800pt ? 64 : 20)
            make.centerX.equalToSuperview()
        }
        
        buttonGroupStackView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(336).priority(.low)
        }
        
        radioGroup.forEach {
            $0.snp.makeConstraints { make in
                make.width.equalTo(view.frame.width - 40)
            }
        }
        
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(54)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(buttonGroupStackView.snp.bottom).offset(20).priority(.low)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(76)
            make.bottom.equalTo(completeButton.snp.top).offset(-20).priority(.high)
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        radioGroup.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            button.rx.tap.asDriver()
                .drive(onNext: {
                    if index == 5 {
                        self.textView.isHidden = false
                    } else {
                        self.textView.endEditing(true)
                        self.textView.isHidden = true
                    }
                    
                    self.selectedReason = self.radioGroup[index].title
                    self.resetButtonUI()
                    self.completeButton.status.accept(.defaultStatus)
                    button.isCurrent = true
                })
                .disposed(by: self.disposeBag)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func bindViewModel() {
        textView.rx.text.orEmpty
            .scan("") { [weak self] (previous, new) -> String in
                if new.count > 40 {
                    self?.selectedReason = previous ?? String(new.prefix(40))
                    return previous ?? String(new.prefix(40))
                } else {
                    self?.selectedReason = new
                    return new
                }
            }
            .subscribe(textView.rx.text)
            .disposed(by: disposeBag)
        
        textView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.textView.text == "어떤 점이 당신을 떠나게 만들었나요?" {
                    owner.textView.text = nil
                    owner.textView.textColor = .textPrimary
                }
            })
            .disposed(by: disposeBag)
        
        textView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.textView.text == nil || owner.textView.text == "" {
                    owner.textView.text = "어떤 점이 당신을 떠나게 만들었나요?"
                    owner.textView.textColor = .iconDisabled
                }
            })
            .disposed(by: disposeBag)
    }
    
    func resetButtonUI(){
        radioGroup.forEach { $0.isCurrent = false }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.endEditing(true)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textViewMoveUp(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if textView.frame.maxY > keyboardSize.minY {
                let layout = textView.frame.maxY - keyboardSize.minY + 20
                    UIView.animate(withDuration: 0.3, animations: {
                        self.mainLabel.transform = CGAffineTransform(translationX: 0, y: -layout)
                        self.buttonGroupStackView.transform = CGAffineTransform(translationX: 0, y: -layout)
                        self.textView.transform = CGAffineTransform(translationX: 0, y: -layout)
                    })
                }
            }
    }
    
    @objc
    func textViewMoveDown() {
        UIView.animate(withDuration: 0.3) {
            self.mainLabel.transform = .identity
            self.buttonGroupStackView.transform = .identity
            self.textView.transform = .identity
        }
    }
}
