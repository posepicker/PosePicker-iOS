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
    let selection = BasicSelection(buttonGroup: ["1인", "2인", "3인", "4인", "5인+"])
    
    let backgroundView = UIView()
        .then {
            $0.backgroundColor = .black
        }
    
    lazy var animationView: LottieAnimationView = .init(name: "lottiePosePicker")
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
    
    let posePickerButton = Button(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "인원수 선택하고 포즈 뽑기!", image: nil)
    
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
        view.backgroundColor = .bgWhite
    }
    
    override func bindViewModel() {
        let input = PosePickViewModel.Input(posePickButtonTapped: posePickerButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.animate
            .drive(onNext: { [unowned self] in
                self.thumbnailImage.isHidden = true
                self.animationView.play(fromProgress: 0, toProgress: 1.2) { _ in
                    self.thumbnailImage.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Objc Functions
}
