//
//  PosePickViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

import Kingfisher
import Lottie
import RxCocoa
import RxSwift

class PosePickViewController: BaseViewController {
    
    // MARK: - Subviews
    let selection = BasicSelection(buttonGroup: ["1인", "2인", "3인", "4인", "5인+"])
    
    let backgroundView = UIView()
        .then {
            $0.backgroundColor = .black
        }
    
    lazy var animationView: LottieAnimationView = .init(name: "lottiePosePicker")
        .then {
            $0.layer.zPosition = 1
            $0.contentMode = .scaleAspectFit
            $0.play(toProgress: 1.2)
        }
    
    let posepickerImage = UIImageView(image: ImageLiteral.imgPosePicker)
        .then {
            $0.layer.zPosition = 0
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFit
        }
    
    let retrievedImage = UIImageView(image: ImageLiteral.imgPosePicker)
        .then {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.isHidden = true
        }
    
    let posePickerButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "인원수 선택하고 포즈 뽑기!", image: nil)
    
    // MARK: - Properties
    var viewModel: PosePickViewModel?
    let isImageLoading = BehaviorRelay<Bool>(value: false)
    let isAnimating = BehaviorRelay<Bool>(value: false)
    let refetchTrigger = PublishSubject<Void>()

    
    // MARK: - Functions
    override func render() {
        view.addSubViews([selection, backgroundView, animationView, posePickerButton, retrievedImage, posepickerImage])
        
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
        
        retrievedImage.snp.makeConstraints { make in
            make.top.trailing.bottom.leading.equalTo(animationView)
        }
        
        posepickerImage.snp.makeConstraints { make in
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
        
        posePickerButton.rx.tap
            .subscribe(onNext: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            })
            .disposed(by: disposeBag)
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(retrievedImageTapped))
        backgroundView.addGestureRecognizer(imageTapGesture)
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        view.addSubView(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubview(retrievedImage)
        retrievedImage.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
//        let input = PosePickViewModel.Input(posePickButtonTapped: posePickerButton.rx.tap, isImageLoading: isImageLoading.asObservable(), isAnimating: isAnimating.asObservable(), refetchTrigger: refetchTrigger.asObservable(), selectedIndex: selection.pressIndex)
//
//        let output = viewModel.transform(input: input)
//        
//        output.animate
//            .drive(onNext: { [unowned self] in
//                self.retrievedImage.image = nil
//                self.isAnimating.accept(true)
//                self.animationView.play() {
//                    if $0 && self.isImageLoading.value { // 애니메이션은 끝났지만 이미지가 여전히 로딩중이면
//                        self.refetchTrigger.onNext(())
//                    } else if $0 {
//                        self.isAnimating.accept(false)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        output.imageUrl
//            .drive(onNext: { [unowned self] urlString in
//                self.isImageLoading.accept(true)
//                self.retrievedImage.kf.setImage(with: URL(string: urlString)) { _ in
//                    self.isImageLoading.accept(false)
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        output.isLoading.bind(to: retrievedImage.rx.isHidden)
//            .disposed(by: disposeBag)
//        
//        output.isLoading.map { !$0 }.bind(to: animationView.rx.isHidden)
//            .disposed(by: disposeBag)
//        
//        output.isPosePickerImageHidden.bind(to: posepickerImage.rx.isHidden)
//            .disposed(by: disposeBag)
    }
    
    // MARK: - Objc Functions
    @objc
    func retrievedImageTapped() {
        guard let retrievedImage = retrievedImage.image else { return }
        let vc = ImagePopUpViewController(mainImage: retrievedImage)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
