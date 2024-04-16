//
//  LoginPopUp.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/22.
//

import UIKit
import RxCocoa
import RxSwift

class LoginPopUpView: UIView {
    // MARK: - Subviews
    let box = UIView()
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .bgWhite
        }
    
    let titleLabel = UILabel()
        .then {
            $0.text = "간편 로그인"
            $0.textColor = .textPrimary
            $0.font = .h4
        }
    
    let infoLabel = UILabel()
        .then {
            $0.textColor = .textPrimary
            $0.textAlignment = .center
            $0.font = .pretendard(.regular, ofSize: 16)
            $0.numberOfLines = 0
            $0.text = "로그인하면 북마크도 쓸 수 있어요!\n간편 로그인으로 3초만에 가입해요."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: $0.text ?? "")
            attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            $0.attributedText = attrString
        }
    
    let kakaoLoginButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgKakaoLogo.withRenderingMode(.alwaysOriginal), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .init(hex: "#FEE500")
            configuration.imagePadding = 10
            let attrString = NSAttributedString(string: "카카오 로그인", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(hex: "#191600")])
            configuration.attributedTitle = AttributedString(attrString)
            $0.configuration = configuration
            $0.semanticContentAttribute = .forceLeftToRight
            $0.backgroundColor = .init(hex: "#FEE500")
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    
    let appleLoginButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgAppleLogo.withRenderingMode(.alwaysOriginal), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .init(hex: "#000000")
            configuration.imagePadding = 10
            let attrString = NSAttributedString(string: "Apple로 로그인", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(hex: "#FFFFFF")])
            configuration.attributedTitle = AttributedString(attrString)
            $0.configuration = configuration
            $0.semanticContentAttribute = .forceLeftToRight
            $0.backgroundColor = .init(hex: "#000000")
            $0.titleLabel?.font = .pretendard(.bold, ofSize: 16)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    
    var loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.startAnimating()
            $0.isHidden = true
            $0.color = .bgSubWhite
        }
    
    // MARK: - Properties
    let alertText = BehaviorRelay<String>(value: "")
    var disposeBag = DisposeBag()
    var isLoading = BehaviorRelay<Bool>(value: false)
    var socialLogin = PublishSubject<SocialLogin>()
    
    enum SocialLogin {
        case apple
        case kakao
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func render() {
        self.addSubViews([box, titleLabel, infoLabel, kakaoLoginButton, appleLoginButton, loadingIndicator])
        
        box.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(box)
            make.top.equalTo(box).offset(32)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(box)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(box).inset(16)
            make.height.equalTo(54)
            make.bottom.equalTo(appleLoginButton.snp.top).offset(-8)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(box).inset(16)
            make.bottom.equalTo(box).offset(-16)
            make.height.equalTo(54)
        }
    }
    
    func configUI() {
        socialLogin.asDriver(onErrorJustReturn: .kakao)
            .drive(onNext: { [weak self] social in
                guard let self = self else { return }
                
                switch social {
                case .kakao:
                    self.loadingIndicator.snp.makeConstraints { make in
                        make.center.equalTo(self.kakaoLoginButton)
                    }
                    self.kakaoLoginButton.titleLabel?.isHidden = true
                    self.kakaoLoginButton.configuration?.image = nil
                    self.kakaoLoginButton.setImage(nil, for: .normal)
                case .apple:
                    self.loadingIndicator.snp.makeConstraints { make in
                        make.center.equalTo(self.appleLoginButton)
                    }
                    self.appleLoginButton.titleLabel?.isHidden = true
                    self.appleLoginButton.configuration?.image = nil
                    self.appleLoginButton.setImage(nil, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        isLoading.map { !$0 }.bind(to: loadingIndicator.rx.isHidden).disposed(by: disposeBag)
    }
}
