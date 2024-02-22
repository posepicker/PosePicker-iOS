//
//  MyPoseGuidelineViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit
import PhotosUI

class MyPoseGuidelineViewController: BaseViewController {
    
    // MARK: - Subviews
    let guidelineBox = UIView()
        .then {
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .textWhite
        }
    
    let mainLabel = UILabel()
        .then {
            $0.font = .pretendard(.bold, ofSize: 16)
            $0.text = "📷 이런 사진을 올려주세요!"
        }
    
    let thumbnail = UIImageView(image: ImageLiteral.imgThumbnail)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let rule1 = UILabel()
        .then {
            $0.text = "· 포즈가 선명하게 나온 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule2 = UILabel()
        .then {
            $0.text = "· QR로 다운로드 받은 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule3 = UILabel()
        .then {
            $0.text = "· 화질이 좋은 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule4 = UILabel()
        .then {
            $0.text = "· 다양한 포즈와 표정 등이 담긴 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let confirmButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "확인", image: nil)
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.isHidden = true
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    // MARK: - Functions
    override func render() {
        view.addSubViews([guidelineBox, mainLabel, thumbnail, rule1, rule2, rule3, rule4, confirmButton, loadingIndicator])
        
        guidelineBox.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(550)
        }
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(guidelineBox).offset(32)
            make.centerX.equalTo(guidelineBox)
        }
        
        thumbnail.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(21.5)
            make.centerX.equalTo(guidelineBox)
            make.width.equalTo(180)
            make.height.equalTo(250)
        }
        
        rule1.snp.makeConstraints { make in
            make.top.equalTo(thumbnail.snp.bottom).offset(24)
            make.leading.equalTo(guidelineBox).offset(22)
            make.height.equalTo(26)
        }
        
        rule2.snp.makeConstraints { make in
            make.top.equalTo(rule1.snp.bottom)
            make.leading.equalTo(rule1)
            make.height.equalTo(26)
        }
        
        rule3.snp.makeConstraints { make in
            make.top.equalTo(rule2.snp.bottom)
            make.leading.equalTo(rule2)
            make.height.equalTo(26)
        }
        
        rule4.snp.makeConstraints { make in
            make.top.equalTo(rule3.snp.bottom)
            make.leading.equalTo(rule3)
            make.height.equalTo(26)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(guidelineBox).inset(16)
            make.height.equalTo(54)
            make.bottom.equalTo(guidelineBox).offset(-16)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .dimmed30
        
        confirmButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                configuration.preferredAssetRepresentationMode = .current
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self?.present(picker, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        if !guidelineBox.frame.contains(location) {
            self.dismiss(animated: true)
        }
    }
}

extension MyPoseGuidelineViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        loadingIndicator.isHidden = false
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async { [weak self] in
                    if let image = image {
                        self?.thumbnail.image = image as? UIImage
                        self?.loadingIndicator.isHidden = true
                    } else {
                        
                        // 이미지를 불러오는데 실패
                        let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: false)
                        popupViewController.modalTransitionStyle = .crossDissolve
                        popupViewController.modalPresentationStyle = .overFullScreen
                        let popupView = popupViewController.popUpView as! PopUpView
                        popupView.alertText.accept("이미지를 불러오는 데 실패했습니다.")
                        self?.loadingIndicator.isHidden = true
                        self?.present(popupViewController, animated: true)
                    }
                }
            }
            
        }
    }
}
