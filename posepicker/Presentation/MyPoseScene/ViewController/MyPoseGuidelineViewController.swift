//
//  MyPoseGuidelineViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit
import PhotosUI
import RxSwift

class MyPoseGuidelineViewController: BaseViewController {
    
    // MARK: - Subviews
    let guidelineBox = UIView()
        .then {
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .textWhite
        }
    
    let mainLabel = UILabel()
        .then {
            $0.font = .pretendard(.bold, ofSize: 18)
            $0.text = "📷 이런 사진을 올려주세요!"
        }
    
    let thumbnail = UIImageView(image: ImageLiteral.imgThumbnail)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let rule1 = UILabel()
        .then {
            $0.text = " · 포즈가 선명하게 나온 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule2 = UILabel()
        .then {
            $0.text = " · QR로 다운로드 받은 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule3 = UILabel()
        .then {
            $0.text = " · 화질이 좋은 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let rule4 = UILabel()
        .then {
            $0.text = " · 다양한 포즈와 표정 등이 담긴 사진"
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.textColor = .textPrimary
        }
    
    let alertLabel = UILabel()
        .then {
            $0.text = "가이드라인을 위반한 사진은\n운영자에 의해 무통보 삭제될 수 있습니다."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 14
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: $0.text ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.pretendard(.medium, ofSize: 12), range: NSMakeRange(0, attrString.length))
            $0.attributedText = attrString
            $0.numberOfLines = 0
            $0.textColor = .textTertiary
        }
    
    let confirmButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "확인", image: nil)
    
    let guidelineCheckButton = UIButton(type: .system)
        .then {
            $0.setTitle("가이드라인 확인하기", for: .normal)
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 14)
            $0.setTitleColor(.textSecondary, for: .normal)
        }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.startAnimating()
            $0.isHidden = true
            $0.color = .mainViolet
        }
    
    // MARK: - Properties
    var viewModel: MyPoseGuidelineViewModel?
    
    private let imageLoadCompletedEvent = PublishSubject<UIImage?>()
    private let imageLoadFailedEvent = PublishSubject<Void>()
    
    // MARK: - Functions
    override func render() {
        let borderBottom = UIView()

        view.addSubViews([guidelineBox, mainLabel, thumbnail, rule1, rule2, rule3, rule4, alertLabel, confirmButton, guidelineCheckButton, borderBottom, loadingIndicator])
        
        guidelineBox.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIScreen.main.isLongerThan800pt ? 124 : 60)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(580)
        }
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(guidelineBox).offset(32)
            make.centerX.equalTo(guidelineBox)
        }
        
        thumbnail.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(12)
            make.centerX.equalTo(guidelineBox)
            make.width.equalTo(160)
            make.height.equalTo(240)
        }
        
        rule1.snp.makeConstraints { make in
            make.top.equalTo(thumbnail.snp.bottom).offset(9)
            make.leading.equalTo(guidelineBox).offset(36)
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
        
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(rule4.snp.bottom).offset(12)
            make.centerX.equalTo(guidelineBox)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(guidelineBox).inset(16)
            make.height.equalTo(54)
            make.top.equalTo(alertLabel.snp.bottom).offset(16)
        }
        
        guidelineCheckButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(12)
            make.centerX.equalTo(guidelineBox)
            make.height.equalTo(22)
        }
        
        borderBottom.backgroundColor = .textSecondary
        borderBottom.snp.makeConstraints { make in
            make.centerX.width.equalTo(guidelineCheckButton)
            make.height.equalTo(1)
            make.top.equalTo(guidelineCheckButton.snp.bottom).offset(-4)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
    }
    
    override func configUI() {
        self.view.backgroundColor = .dimmed70
        
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
    
    override func bindViewModel() {
        let input = MyPoseGuidelineViewModel.Input(
            guidelineCheckButtonTapEvent: guidelineCheckButton.rx.tap.asObservable(),
            imageLoadCompletedEvent: imageLoadCompletedEvent,
            imageLoadFailedEvent: imageLoadFailedEvent
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
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
                    if let image = image as? UIImage {
                        self?.imageLoadCompletedEvent.onNext(image)
                        self?.loadingIndicator.isHidden = true
//                        self?.navigationController?.pushViewController(MyPoseViewController(registeredImage: image as? UIImage), animated: true)
                    } else {
                        self?.loadingIndicator.isHidden = true
                        self?.imageLoadFailedEvent.onNext(())
                    }
                }
            }
            
        }
    }
}
