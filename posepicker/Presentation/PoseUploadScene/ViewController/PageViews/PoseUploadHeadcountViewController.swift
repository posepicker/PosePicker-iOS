//
//  MyPoseHeadcountViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit
import RxCocoa
import RxSwift

class PoseUploadHeadcountViewController: BaseViewController {
    
    // MARK: - Subviews
    let scrollView = UIScrollView()
        .then { sv in
            let view = UIView()
            sv.addSubview(view)
            view.snp.makeConstraints {
                $0.top.equalTo(sv.contentLayoutGuide.snp.top)
                $0.leading.equalTo(sv.contentLayoutGuide.snp.leading)
                $0.trailing.equalTo(sv.contentLayoutGuide.snp.trailing)
                $0.bottom.equalTo(sv.contentLayoutGuide.snp.bottom)

                $0.leading.equalTo(sv.frameLayoutGuide.snp.leading)
                $0.trailing.equalTo(sv.frameLayoutGuide.snp.trailing)
                $0.height.equalTo(sv.frameLayoutGuide.snp.height).priority(.low)
            }
        }
    
    let mainLabel = UILabel()
        .then {
            let attributedText = NSMutableAttributedString(string: "몇 명", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "과\n찍으셨나요?", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 6
            $0.contentMode = .scaleAspectFill
        }
    
    let expandButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgExpand.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.backgroundColor = .dimmed30
        }
    
    let imageLabel = UILabel()
        .then {
            $0.text = "등록된 이미지"
            $0.textColor = .textTertiary
            $0.font = .caption
        }
    
    let headcountButtons: [MyPoseSelectButton] = [MyPoseSelectButton(title: "1인", isCurrent: true), MyPoseSelectButton(title: "2인"), MyPoseSelectButton(title: "3인"), MyPoseSelectButton(title: "4인"), MyPoseSelectButton(title: "5인 이상")]
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    let selectedHeadCount = BehaviorRelay<String>(value: "1인")
    var viewModel: PoseUploadHeadcountViewModel?
    
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
        view.addSubViews([scrollView, nextButton])
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top)
        }
        
        let firstLineButtons = UIStackView(arrangedSubviews: [headcountButtons[0], headcountButtons[1], headcountButtons[2]])
            .then {
                $0.axis = .horizontal
                $0.alignment = .fill
                $0.distribution = .fillEqually
                $0.spacing = 12
            }
        
        let secondLineButtons = UIStackView(arrangedSubviews: [headcountButtons[3], headcountButtons[4]])
            .then {
                $0.axis = .horizontal
                $0.alignment = .fill
                $0.distribution = .fillEqually
                $0.spacing = 12
            }
        
        scrollView.subviews.first!.addSubViews([mainLabel, firstLineButtons, secondLineButtons, registeredImageView, imageLabel, expandButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(80)
        }
        
        firstLineButtons.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(mainLabel.snp.bottom).offset(36)
            make.height.equalTo(108)
        }
        
        secondLineButtons.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(headcountButtons[1])
            make.top.equalTo(firstLineButtons.snp.bottom).offset(12)
            make.height.equalTo(108)
        }
        
        registeredImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondLineButtons.snp.bottom).offset(36)
            make.height.equalTo(160)
            make.width.equalTo(120)
        }

        expandButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.center.equalTo(registeredImageView)
        }
        
        imageLabel.snp.makeConstraints { make in
            make.top.equalTo(registeredImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        headcountButtons.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            
            button.rx.tap
                .subscribe(onNext: {
                    self.resetButtonUI()
                    button.isCurrent = true
                    
                    self.selectedHeadCount.accept(button.title == "5인 이상" ? "5인" : button.title)
                })
                .disposed(by: self.disposeBag)
        }
        headcountButtons[0].isCurrent = true

        expandButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let absoluteOrigin: CGPoint? = self.registeredImageView.superview?.convert(self.registeredImageView.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
                let frame = CGRectMake(absoluteOrigin?.x ?? 0, absoluteOrigin?.y ?? 0, 120, 160)
                let vc = PoseUploadImageDetailViewController(registeredImage: self.registeredImage, frame: frame)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func bindViewModel() {
        let input = PoseUploadHeadcountViewModel.Input(
            nextButtonTapEvent: nextButton.rx.tap.asObservable(),
            expandButtonTapEvent: expandButton.rx.tap.flatMapLatest { [weak self] _ -> Observable<(CGPoint, UIImage?)> in
                guard let self = self else { return .empty() }
                let absoluteOrigin = self.registeredImageView.superview?.convert(self.registeredImageView.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
                return Observable.just((absoluteOrigin, self.registeredImage))
            },
            selectedHeadCount: selectedHeadCount.asObservable()
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
    }
    
    func resetButtonUI() {
        headcountButtons.forEach { $0.isCurrent = false }
    }
}
