//
//  PullToRefresh.swift
//  posepicker
//
//  Created by 박경준 on 5/29/24.
//

import UIKit
import Lottie

class PullToRefreshView: UIView {

    // MARK: - Subviews
    let backgroundImageView = UIImageView()
        .then {
            $0.image = ImageLiteral.imgBanner
        }
    
    let animationView: LottieAnimationView = .init(name: "lottiePosePicker")
        .then {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.play()
        }
    
    let title = UILabel()
        .then {
            $0.text = "어떤 포즈가 나올지 궁금하지-?"
            $0.font = .subTitle1
        }
    
    // MARK: - Initialization
    required init() {
        super.init(frame: .zero)
        render()
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func render() {
        self.addSubViews([backgroundImageView, title, animationView])
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        title.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        animationView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configUI() {
        
    }
}
