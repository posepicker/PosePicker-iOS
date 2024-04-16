//
//  ImagePopUpViewController.swift
//  posepicker
//
//  Created by 박경준 on 1/22/24.
//

import UIKit

class ImagePopUpViewController: BaseViewController {
    
    // MARK: - Subviews
    lazy var imageView = UIImageView(image: self.mainImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let gestureView = UIView()
        .then {
            $0.backgroundColor = .clear
        }
    
    // MARK: - Properties
    let mainImage: UIImage?
    
    // MARK: - Initialization
    init(mainImage: UIImage?) {
        self.mainImage = mainImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        view.addSubViews([gestureView, imageView])
        
        gestureView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .dimmed70
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        view.addSubview(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
}
