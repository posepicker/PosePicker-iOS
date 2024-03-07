//
//  PoseDetailMoreViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/7/24.
//

import UIKit

class PoseDetailMoreViewController: BaseViewController {

    // MARK: - Subviews
    
    lazy var navigationBar = UINavigationBar()
        .then {
            let closeButton = UIBarButtonItem(image: ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault), style: .plain, target: self, action: #selector(closeButtonTapped))

            let navigationItem = UINavigationItem(title: "")
            navigationItem.rightBarButtonItem = closeButton
            $0.items = [navigationItem]
            $0.barTintColor = .bgWhite
        }
    
    let reportButton = UIButton(type: .system)
        .then {
            $0.setTitle("신고하기", for: .normal)
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.contentHorizontalAlignment = .leading
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    let blockButton = UIButton(type: .system)
        .then {
            $0.setTitle("차단하기", for: .normal)
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.contentHorizontalAlignment = .leading
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    // MARK: - Properties
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentationController?.containerView?.backgroundColor = .dimmed70
    }
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([navigationBar, reportButton, blockButton])
        
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.top)
            make.height.equalTo(50)
        }
        
        reportButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalTo(view).inset(20)
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        blockButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalTo(view).inset(20)
            make.top.equalTo(reportButton.snp.bottom)
        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
        
        // 네비게이션 바 보더라인 삭제
        self.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layoutIfNeeded()
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}
