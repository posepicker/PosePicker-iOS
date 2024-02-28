//
//  MyPoseImageDetailViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/28/24.
//

import UIKit

class MyPoseImageDetailViewController: BaseViewController {

    // MARK: - Subviews
    lazy var imageView = UIImageView(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
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
        view.addSubViews([imageView])
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK:  화면 dismiss 로직
    // 1. scale 1값 아니면 dismiss 안함
    // 2. scale 1일때 좌표 아래로 내려가면 dismiss
    override func configUI() {
        view.backgroundColor = .dimmed70
        imageView.enableZoom()
        imageView.enableDrag()
    }
}
