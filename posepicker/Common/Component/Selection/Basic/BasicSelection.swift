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
    lazy var stackView = UIStackView(arrangedSubviews: [buttonFirst, buttonSecond, buttonThird, buttonFourth, buttonFifth])
        .then {
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 0
            $0.axis = .horizontal
        }
    
    let buttonFirst = BasicButton(type: .system)
        .then {
            $0.setTitle("1인", for: .normal)
            $0.position.accept(.left)
            $0.isPressed.accept(true)
        }
    let buttonSecond = BasicButton(type: .system)
        .then {
            $0.setTitle("2인", for: .normal)
        }
    let buttonThird = BasicButton(type: .system)
        .then {
            $0.setTitle("3인", for: .normal)
        }
    let buttonFourth = BasicButton(type: .system)
        .then {
            $0.setTitle("4인", for: .normal)
        }
    let buttonFifth = BasicButton(type: .system)
        .then {
            $0.setTitle("5인+", for: .normal)
            $0.position.accept(.right)
        }
    
    // MARK: - Properties
    var pressIndex = BehaviorRelay<Int>(value: 0)
    var disposeBag = DisposeBag()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        let buttons = [buttonFirst, buttonSecond, buttonThird, buttonFourth, buttonFifth]
        
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
            .drive(onNext: { index in
                buttons.enumerated().forEach { param in
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
