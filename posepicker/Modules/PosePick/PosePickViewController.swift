//
//  PosePickViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import Lottie

class PosePickViewController: BaseViewController {
    
    // MARK: - Subviews
    let selection = BasicSelection()
    
    let backgroundView = UIView()
        .then {
            $0.backgroundColor = .black
        }
    
    lazy var animationView: LottieAnimationView = .init(name: "posepicker")
        .then {
            $0.contentMode = .scaleAspectFit
            $0.play(toProgress: 1.2) { completed in
                self.thumbnailImage.isHidden = false
            }
        }
    
    let thumbnailImage = UIImageView(image: ImageLiteral.imgPosePicker)
        .then {
            $0.clipsToBounds = true
            $0.isHidden = true
            $0.contentMode = .scaleAspectFit
        }
    
    let posePickerButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textWhite, for: .normal)
            $0.backgroundColor = .mainViolet
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.setTitle("인원수 선택하고 포즈 뽑기!", for: .normal)
        }
    
    // MARK: - Properties
    var viewModel: PosePickViewModel
    
    // MARK: - Life Cycles
    init(viewModel: PosePickViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        view.addSubViews([selection, backgroundView, animationView, thumbnailImage, posePickerButton])
        
        selection.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(selection.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(posePickerButton.snp.top).offset(-30)
        }
        
        animationView.snp.makeConstraints { make in
            make.top.equalTo(selection.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(posePickerButton.snp.top).offset(-30)
        }
        
        thumbnailImage.snp.makeConstraints { make in
            make.top.trailing.bottom.leading.equalTo(animationView)
        }
        
        posePickerButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(animationView)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgSubWhite
        
        posePickerButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.thumbnailImage.isHidden = true
                self.animationView.play(fromProgress: 0, toProgress: 1.2) { _ in
                    self.thumbnailImage.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = PosePickViewModel.Input(posePickButtonTapped: posePickerButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        
    }
    
    // MARK: - Objc Functions
}
