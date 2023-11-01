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
    
    lazy var informationStackView = UIStackView(arrangedSubviews: [self.informationLabel, self.informationImageView])
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
    
    let informationImageView = UIImageView(image: ImageLiteral.imgInfo24.withRenderingMode(.alwaysOriginal))
    
    let mainLabel = UILabel()
        .then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.font = .h1
        }
    
    var animationView: LottieAnimationView = .init(name: "lottiePoseTalk")
        .then {
            $0.loopMode = .loop
            $0.play()
        }
    
    let selectButton = Button(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "제시어 뽑기", image: nil)
    
    // MARK: - Properties
    
    let viewModel: PoseTalkViewModel
    var isAnimating = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Life Cycles
    
    init(viewModel: PoseTalkViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([informationStackView, mainLabel, animationView, selectButton])
        
        informationStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIScreen.main.isWiderThan375pt ? 64: 40)
            make.centerX.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 100)
        }
        
        animationView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset( UIScreen.main.isWiderThan375pt ? 16 : 0)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIScreen.main.isWiderThan375pt ? 0 : 40)
        }
        
        selectButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
    }
    
    override func bindViewModel() {
        let input = PoseTalkViewModel.Input(poseTalkButtonTapped: selectButton.rx.controlEvent(.touchUpInside), isAnimating: isAnimating.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.animate
            .drive(onNext: { [unowned self] in
                self.animationView.pause()
                self.animationView.loopMode = .playOnce
                self.animationView.animation = LottieAnimation.named("lottiePoseTalkTap")
                self.isAnimating.accept(true)
                self.animationView.play() {
                    if $0 {
                        self.isAnimating.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .flatMapLatest { isLoading -> Observable<String> in
                if isLoading {
                    return Observable<String>.empty()
                } else {
                    return output.poseWord
                }
            }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [unowned self] in
                self.mainLabel.text = $0
            })
            .disposed(by: disposeBag)
            
    }
}
