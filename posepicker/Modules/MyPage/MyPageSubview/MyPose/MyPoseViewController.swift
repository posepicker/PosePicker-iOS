//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit

class MyPoseViewController: BaseViewController {
    
    // MARK: - Subviews
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    
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
        view.addSubViews([registeredImageView, nextButton])
        
        registeredImageView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(160)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-27)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        view.backgroundColor = .bgWhite
    }
}
