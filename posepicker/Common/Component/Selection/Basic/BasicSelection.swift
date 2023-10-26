//
//  BasicSelection.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import UIKit
import RxCocoa
import RxSwift

class BasicSelection: UIView {
    
    // MARK: - Subviews
    var stackView: UIStackView
    var buttons: [BasicButton] = []
    
    // MARK: - Properties
    var pressIndex = BehaviorRelay<Int>(value: 0)
    var disposeBag = DisposeBag()
    var buttonGroup: [String]

    // MARK: - Initialization
    required init(buttonGroup: [String]) {
        self.buttonGroup = buttonGroup
        
        self.buttons = buttonGroup.enumerated().map { (offset, element) in
            let button = BasicButton(type: .system)
            button.setTitle(element, for: .normal)
            if offset == 0 {
                button.position.accept(.left)
                button.isPressed.accept(true)
            } else if offset == buttonGroup.count - 1 {
                button.position.accept(.right)
            }
            return button
        }
        
        self.stackView = UIStackView(arrangedSubviews: self.buttons)
        
        super.init(frame: .zero)
        
        render()
        bindUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func render() {
        self.addSubview(stackView)
    
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(20)
            make.top.bottom.equalTo(self)
        }
    }
    
    func bindUI() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        buttons.forEach {
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 14)
        }
        
        buttons.enumerated().forEach { param in
            param.element.rx.tap.asDriver()
                .drive(onNext: { [unowned self] in
                    self.pressIndex.accept(param.offset)
                })
                .disposed(by: disposeBag)
        }
        
        pressIndex.asDriver()
            .drive(onNext: { [unowned self] index in
                self.buttons.enumerated().forEach { param in
                    if param.offset == index {
                        param.element.setTitleColor(.mainVioletDark, for: .normal)
                        param.element.isPressed.accept(true)
                    } else {
                        param.element.setTitleColor(.textSecondary, for: .normal)
                        param.element.isPressed.accept(false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
