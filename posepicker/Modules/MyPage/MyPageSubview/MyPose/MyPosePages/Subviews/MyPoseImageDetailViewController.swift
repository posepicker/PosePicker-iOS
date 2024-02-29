//
//  MyPoseImageDetailViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/28/24.
//

import UIKit
import RxSwift
import SnapKit

class MyPoseImageDetailViewController: BaseViewController {

    // MARK: - Subviews
    lazy var imageView = UIImageViewWithDismissNotification(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleToFill
        }
    
    // MARK: - Properties
    let registeredImage: UIImage?
    let frame: CGRect?
    
    // MARK: - Initialization
    init(registeredImage: UIImage?, frame: CGRect?) {
        self.registeredImage = registeredImage?.resize(newWidth: UIScreen.main.bounds.width)
        self.frame = frame
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
            make.center.equalToSuperview()
        }
    }
    
    // MARK:  화면 dismiss 로직
    // 1. scale 1값 아니면 dismiss 안함
    // 2. scale 1일때 좌표 아래로 내려가면 dismiss
    override func configUI() {
        view.backgroundColor = .dimmed70
        imageView.enableZoom()
        imageView.enableDrag()
        
        imageView.dismissObservable
            .subscribe(onNext: { [weak self] dismiss in
                if !dismiss { return }
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    guard let frame = self.frame else { return }
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.snp.removeConstraints()
                    self.imageView.frame = frame
                    
                    self.imageView.setNeedsLayout()
                    self.imageView.layoutIfNeeded()
                } completion: { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        imageView.backgroundAlphaObservable
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] alphaRatio in
                self?.view.backgroundColor = .init(hex: "#000000", alpha: 0.7 - 0.4 * alphaRatio)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
}
