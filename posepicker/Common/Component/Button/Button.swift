//
//  Button.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class Button: UIButton {
    
    // MARK: - Subviews
    let buttonImage: UIImage
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    enum ButtonStatus {
        case defaultStatus
        case pressed
        case disabled
    }
    
    enum imagePosition {
        case none
        case left
        case right
    }
    
    var status = BehaviorRelay<ButtonStatus>(value: .defaultStatus)
    var isFill: Bool
    var position: imagePosition
    var buttonTitle: String

    // MARK: - Initialization
    required init(status: ButtonStatus, isFill: Bool, position: imagePosition, buttonTitle: String) {
        self.status.accept(status)
        self.isFill = isFill
        self.position = position
        self.buttonTitle = buttonTitle
        self.buttonImage = ImageLiteral.imgBookmarkOff24
        super.init(frame: .zero)
        
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func configUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        
        self.setTitle(self.buttonTitle, for: .normal)
        
        if self.isFill { // FILL BUTTON
            self.setTitleColor(.white, for: .normal)
            self.setTitleColor(.textWhite, for: .disabled)
        } else { // OUTLINE BUTTON
            self.setTitleColor(.mainVioletDark, for: .normal)
            self.setTitleColor(.iconDisabled, for: .disabled)
            self.layer.borderColor = UIColor.mainVioletDark.cgColor
            self.layer.borderWidth = 1
        }
        
        setImagePosition()
        
        self.status.asDriver()
            .drive(onNext: { [unowned self] in
                if self.isFill {
                    switch $0 {
                    case .defaultStatus:
                        self.backgroundColor = .mainViolet
                    case .pressed:
                        self.backgroundColor = .mainVioletDark
                    case .disabled:
                        self.isEnabled = false
                        self.backgroundColor = .iconDisabled
                    }
                } else {
                    switch $0 {
                    case .defaultStatus:
                        self.backgroundColor = .violet050
                    case .pressed:
                        self.backgroundColor = .violet200
                    case .disabled:
                        self.isEnabled = false
                        self.layer.borderColor = UIColor.iconDisabled.cgColor
                        self.backgroundColor = .iconDisabled
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.rx.controlEvent(.touchDown).asDriver()
            .drive(onNext: { [unowned self] in
                self.status.accept(.pressed)
                self.setImage(ImageLiteral.imgBookmarkFill24.withRenderingMode(.alwaysOriginal), for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.rx.controlEvent(.touchUpInside).asDriver()
            .drive(onNext: { [unowned self] in
                self.status.accept(.defaultStatus)
                self.setImage(ImageLiteral.imgBookmarkOff24.withRenderingMode(.alwaysOriginal), for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    func setImagePosition() {
        guard let titleLabel = self.titleLabel else { return }
        if self.position == .none { return }
        
        switch self.position {
        case .left:
            self.setImage(ImageLiteral.imgBookmarkOff24, for: .normal)
            self.semanticContentAttribute = .forceLeftToRight
        case .right:
            self.setImage(ImageLiteral.imgBookmarkOff24, for: .normal)
            self.semanticContentAttribute = .forceRightToLeft
        case .none:
            break
        }
    }
}
