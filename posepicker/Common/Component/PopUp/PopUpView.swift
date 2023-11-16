//
//  PopUpView.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/16.
//

import UIKit
import RxCocoa
import RxSwift

class PopUpView: UIView {

    // MARK: - Subviews
    let box = UIView()
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .bgWhite
        }
    
    let alertLabel = UILabel()
        .then {
            $0.font = .pretendard(.regular, ofSize: 16)
        }
    
    let completeButton = Button(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "확인", image: nil)
    
    // MARK: - Properties
    let alertText = BehaviorRelay<String>(value: "")
    var disposeBag = DisposeBag()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
        configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func render() {
        self.addSubViews([box, alertLabel, completeButton])
        
        box.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(box.snp.top).offset(32)
            make.centerX.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
    }
    
    func configUI() {
        alertText.asObservable().bind(to: alertLabel.rx.text).disposed(by: disposeBag)
    }
}
