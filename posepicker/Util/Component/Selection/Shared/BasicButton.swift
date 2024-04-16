//
//  BasicButton.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import UIKit
import RxCocoa
import RxSwift

class BasicButton: UIButton {

    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    enum BasicButtonPosition {
        case left
        case center
        case right
    }
    
    var isPressed = BehaviorRelay<Bool>(value: false)
    var position = BehaviorRelay<BasicButtonPosition>(value: .center)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func configUI() {
        position.asDriver()
            .drive(onNext: { [unowned self] in
                // cornerRadius
                switch $0 {
                case .left:
                    self.clipsToBounds = true
                    self.layer.cornerRadius = 10
                    self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                case .center:
                    self.clipsToBounds = false
                    self.layer.cornerRadius = 0
                case .right:
                    self.clipsToBounds = true
                    self.layer.cornerRadius = 10
                    self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                }
            })
            .disposed(by: disposeBag)
        
        isPressed.asDriver()
            .drive(onNext: { [unowned self] in
                if $0 {
                    self.backgroundColor = .violet100
                    self.layer.borderColor = UIColor.mainViolet.cgColor
                    self.layer.borderWidth = 1
                } else {
                    self.backgroundColor = .bgSubWhite
                    self.layer.borderColor = UIColor.borderDefault.cgColor
                    self.layer.borderWidth = 1
                }
            })
            .disposed(by: disposeBag)
    }
}
