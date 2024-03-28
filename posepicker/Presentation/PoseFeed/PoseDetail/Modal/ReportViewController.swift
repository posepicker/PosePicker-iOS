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
    
    let completeButton = PosePickButton(status: .disabled, isFill: true, position: .none, buttonTitle: "신고하기", image: nil)
    
    let textView = UITextView()
        .then {
            $0.textColor = .iconDisabled
            $0.text = "신고하는 이유가 무엇인가요?"
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
        RadioButton(title: "스팸 또는 중복 콘텐츠"),
        RadioButton(title: "폭력적 또는 선정적 콘텐츠"),
        RadioButton(title: "초상권 등 기타 법적 문제 침해"),
        RadioButton(title: "기타 입력"),
    ]
    
    let poseId: Int
    
    var selectedReason: String = ""
    
    // MARK: - Initialization
    
    init(poseId: Int) {
        self.poseId = poseId
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([mainLabel, buttonGroupStackView, completeButton, textView])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            make.centerX.equalToSuperview()
        }
        
        buttonGroupStackView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(224)
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
            make.top.equalTo(buttonGroupStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(76)
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
        self.navigationItem.leftBarButtonItem = closeButton
        
        radioGroup.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            button.rx.tap.asDriver()
                .drive(onNext: {
                    if index == 3 {
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
        
        completeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: true)
                guard let popupView = popupVC.popUpView as? PopUpView else { return }
                popupView.alertText.accept("정말 신고하시겠어요?")
                popupView.confirmButton.setTitle("신고하기", for: .normal)
                popupView.confirmButton.backgroundColor = .warningDark
                
                popupView.cancelButton.backgroundColor = .init(hex: "#F7F7FA")
                popupView.cancelButton.setTitleColor(.textSecondary, for: .normal)
                popupVC.modalPresentationStyle = .overFullScreen
                popupVC.modalTransitionStyle = .crossDissolve
                
                // 취소하기 버튼 탭
                popupView.cancelButton.rx.tap
                    .asDriver()
                    .drive(onNext: {
                        popupVC.dismiss(animated: true)
                    })
                    .disposed(by: self.disposeBag)
                
                popupView.confirmButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
//                        guard let self = self else { return }
//                        let defaults = UserDefaults.standard
//                        defaults.set(self.selectedReason, forKey: "\(self.poseId)")
//                        popupVC.dismiss(animated: true) {
//                            // 포즈피드까지 이동
//                            // 태그 새로고침
//                            let navigation = self.view.window!.rootViewController as? UINavigationController
//                            let rootVC = navigation?.viewControllers.first as? CommonViewController
//                            let rootNavigationVC = rootVC?.viewControllers[2] as? UINavigationController
//                            let posefeedVC = rootNavigationVC?.viewControllers.first as? PoseFeedViewController
//                            posefeedVC?.tagResetTrigger.onNext(())
//                            
//                            self.view.window!.rootViewController?.dismiss(animated: true) {
//                                posefeedVC?.reportCompletedTrigger.onNext(())
//                            }
//                        }
                    })
                    .disposed(by: disposeBag)
                
                self.present(popupVC, animated: true)
            })
            .disposed(by: disposeBag)
        
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
                if owner.textView.text == "신고하는 이유가 무엇인가요?" {
                    owner.textView.text = nil
                    owner.textView.textColor = .textPrimary
                }
            })
            .disposed(by: disposeBag)
        
        textView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.textView.text == nil || owner.textView.text == "" {
                    owner.textView.text = "신고하는 이유가 무엇인가요?"
                    owner.textView.textColor = .iconDisabled
                }
            })
            .disposed(by: disposeBag)
    }
    
    func resetButtonUI(){
        radioGroup.forEach { $0.isCurrent = false }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.endEditing(true)
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
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
