//
//  MyPoseFramecountViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit

class MyPoseFramecountViewController: BaseViewController {

    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            
            let attributedText = NSMutableAttributedString(string: "몇 컷 프레임", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "으로\n찍으셨나요?", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    let framecountButtons: [MyPoseSelectButton] = [MyPoseSelectButton(title: "1컷", isCurrent: true), MyPoseSelectButton(title: "3컷"), MyPoseSelectButton(title: "4컷"), MyPoseSelectButton(title: "6컷"), MyPoseSelectButton(title: "8컷 이상")]
    
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
        let firstLineButtons = UIStackView(arrangedSubviews: [framecountButtons[0], framecountButtons[1], framecountButtons[2]])
            .then {
                $0.axis = .horizontal
                $0.alignment = .fill
                $0.distribution = .fillEqually
                $0.spacing = 12
            }
        
        let secondLineButtons = UIStackView(arrangedSubviews: [framecountButtons[3], framecountButtons[4]])
            .then {
                $0.axis = .horizontal
                $0.alignment = .fill
                $0.distribution = .fillEqually
                $0.spacing = 12
            }
        
        view.addSubViews([mainLabel, firstLineButtons, secondLineButtons, registeredImageView, nextButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        firstLineButtons.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(mainLabel.snp.bottom).offset(36)
            make.height.equalTo(108)
        }
        
        secondLineButtons.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(framecountButtons[1])
            make.top.equalTo(firstLineButtons.snp.bottom).offset(12)
            make.height.equalTo(108)
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
        framecountButtons.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            
            button.rx.tap
                .subscribe(onNext: {
                    self.resetButtonUI()
                    button.isCurrent = true
                })
                .disposed(by: self.disposeBag)
        }
        framecountButtons[0].isCurrent = true
    }
    
    func resetButtonUI() {
        framecountButtons.forEach { $0.isCurrent = false }
    }
}
