//
//  MyPoseFramecountViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit
import RxCocoa
import RxSwift

class PoseUploadFramecountViewController: BaseViewController {

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
            let attributedText = NSMutableAttributedString(string: "몇 컷 프레임", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "으로\n찍으셨나요?", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    let framecountButtons: [MyPoseSelectButton] = [MyPoseSelectButton(title: "1컷", isCurrent: true), MyPoseSelectButton(title: "3컷"), MyPoseSelectButton(title: "4컷"), MyPoseSelectButton(title: "6컷"), MyPoseSelectButton(title: "8컷 이상")]
    
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 6
            $0.contentMode = .scaleAspectFill
        }
    
    let imageLabel = UILabel()
        .then {
            $0.text = "등록된 이미지"
            $0.textColor = .textTertiary
            $0.font = .caption
        }
    
    let expandButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgExpand.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.backgroundColor = .dimmed30
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    let selectedFrameCount = BehaviorRelay<String>(value: "1컷")
    var viewModel: PoseUploadFramecountViewModel?
    
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
        
        scrollView.subviews.first!.addSubViews([mainLabel, firstLineButtons, secondLineButtons, registeredImageView, expandButton, imageLabel])
        
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
            make.trailing.equalTo(framecountButtons[1])
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
        framecountButtons.enumerated().forEach { [weak self] index, button in
            guard let self = self else { return }
            
            button.rx.tap
                .subscribe(onNext: {
                    self.resetButtonUI()
                    button.isCurrent = true
                    self.selectedFrameCount.accept(button.title == "8컷 이상" ? "8컷" : button.title)
                })
                .disposed(by: self.disposeBag)
        }
        framecountButtons[0].isCurrent = true
        
        expandButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let absoluteOrigin: CGPoint? = self.registeredImageView.superview?.convert(self.registeredImageView.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
                let frame = CGRectMake(absoluteOrigin?.x ?? 0, absoluteOrigin?.y ?? 0, 120, 160)
                let vc = MyPoseImageDetailViewController(registeredImage: self.registeredImage, frame: frame)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = PoseUploadFramecountViewModel.Input(
            nextButtonTapEvent: nextButton.rx.tap.asObservable(),
            expandButtonTapEvent: expandButton.rx.tap.flatMapLatest { [weak self] _ -> Observable<(CGPoint, UIImage?)> in
                guard let self = self else { return .empty() }
                let absoluteOrigin = self.registeredImageView.superview?.convert(self.registeredImageView.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
                return Observable.just((absoluteOrigin, self.registeredImage))
            }
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
    }
    
    func resetButtonUI() {
        framecountButtons.forEach { $0.isCurrent = false }
    }
}


private extension PoseUploadFramecountViewController {
    func configureOutput(_ output: PoseUploadFramecountViewModel.Output?) {
        
    }
}
