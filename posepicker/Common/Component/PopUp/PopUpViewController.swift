//
//  PopUpViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/16.
//

import UIKit
import RxSwift

class PopUpViewController: BaseViewController {

    // MARK: - Subviews
    let popUpView = PopUpView()
    
    // MARK: - Properties
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([popUpView])
        
        popUpView.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(158)
            make.center.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .init(hex: "#000000", alpha: 0.3)
        
        popUpView.completeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
