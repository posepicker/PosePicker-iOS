//
//  PoseTalkViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

import RxCocoa
import RxSwift
import Lottie

class PoseTalkViewController: BaseViewController {
    
    // MARK: - Subviews
    
    lazy var informationStackView = UIStackView(arrangedSubviews: [self.informationLabel, self.informationTooltipButton])
        .then {
            $0.alignment = .center
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 0
        }
    
    let informationLabel = UILabel()
        .then {
            $0.textAlignment = .center
            $0.textColor = .mainViolet
            $0.font = .h3
            $0.text = "뽑은 제시어"
        }
    
    let informationTooltipButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgInfo24.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    
    let mainLabel = UILabel()
        .then {
            $0.text = "제시어에 맞춰\n포즈를 취해요!"
            $0.textColor = .textPrimary
            $0.layer.zPosition = 999
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.font = .h1
        }
    
    var animationView: LottieAnimationView = .init(name: "lottiePoseTalk")
        .then {
            $0.backgroundColor = .clear
            $0.loopMode = .loop
            $0.play()
        }
    
    let selectButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "제시어 뽑기", image: nil)
    
    let toolTip = ToolTip()
        .then {
            $0.layer.zPosition = 999
        }
    
    // MARK: - Properties
    
    var viewModel: PoseTalkViewModel?
    var isAnimating = BehaviorRelay<Bool>(value: false) // 초기 화면 접속시에 애니메이션 처리 해야됨
    
    // MARK: - Life Cycles
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toolTip.isHidden = true
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([informationStackView, toolTip, mainLabel, animationView, selectButton])
        
        informationStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIScreen.main.isWiderThan375pt ? 64: 40).priority(.high)
            make.centerX.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(8).priority(.high)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 100)
        }
        
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            let mainLabelHeight = "제시어에 맞춰\n포즈를 취해요!".height(withConstrainedWidth: UIScreen.main.bounds.width - 100, font: .h1)
            make.top.equalTo(mainLabel.snp.top).offset(mainLabelHeight)
            make.bottom.lessThanOrEqualTo(selectButton.snp.top).offset(-10)
        }
        
        selectButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        viewModel?.coordinator?.rootViewController.view.addSubViews([toolTip])
    
        let segmentHeight = viewModel?.coordinator?.rootViewController.segmentControl.frame.height ?? 100
        let headerHeight = UIScreen.main.isWiderThan375pt ? viewModel?.coordinator?.rootViewController.header.frame.height ?? 20 - 10 : viewModel?.coordinator?.rootViewController.header.frame.height ?? 20 - 20
        
        toolTip.snp.makeConstraints { make in
            make.leading.equalTo(UIScreen.main.isWiderThan375pt ? 76 : 66)
            make.width.equalTo(UIScreen.main.isWiderThan375pt ? 230 : 210)
            make.height.equalTo(UIScreen.main.isWiderThan375pt ? 80 : 68)
            make.top.equalTo(viewModel?.coordinator?.rootViewController.view.safeAreaLayoutGuide.snp.top ?? self.view.snp.top).offset(segmentHeight + headerHeight)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
        
        toolTip.closeButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.toolTip.isHidden = true
            })
            .disposed(by: disposeBag)
        
        informationTooltipButton.rx.tap.asDriver()
            .drive(onNext: {
                self.toolTip.isHidden = false
            })
            .disposed(by: disposeBag)
        
        selectButton.rx.tap
            .subscribe(onNext: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = PoseTalkViewModel.Input(
            poseTalkButtonTapped: selectButton.rx.controlEvent(.touchUpInside),
            isAnimating: isAnimating
        )
        
        let output = viewModel!.transform(input: input)
        self.configureViewModelOutput(output)
    }
    
    // MARK: - Objc Functions
}

private extension PoseTalkViewController {
    func configureViewModelOutput(_ output: PoseTalkViewModel.Output?) {
        
        output?.poseWord
            .asDriver(onErrorJustReturn: "오류")
            .drive(onNext: { [weak self] in
                self?.mainLabel.text = $0
            })
            .disposed(by: disposeBag)
        
        output?.animate
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.animationView.pause()
                self.animationView.loopMode = .playOnce
                self.animationView.animation = LottieAnimation.named("lottiePoseTalkTap")
                
                // 애니메이션 로티뷰 사이즈 조정 -> 2줄 텍스트 기준 높이값 계산하는 로직
                self.animationView.snp.updateConstraints { make in
                    let mainLabelHeight = "제시어에 맞춰\n포즈를 취해요!".height(withConstrainedWidth: UIScreen.main.bounds.width - 100, font: .h1)
                    make.top.equalTo(self.mainLabel.snp.top).offset(mainLabelHeight + 6)
                    make.leading.equalToSuperview().offset(-40)
                    make.trailing.equalToSuperview().offset(44)
                }
        
                self.isAnimating.accept(true)
                self.animationView.play() {
                    if $0 {
                        self.isAnimating.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
