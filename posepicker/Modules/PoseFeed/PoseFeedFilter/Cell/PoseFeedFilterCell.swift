//
//  PoseFeedFilterCell.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit

class PoseFeedFilterCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    let label = UILabel()
        .then {
            $0.textColor = .textSecondary
            $0.font = .pretendard(.medium, ofSize: 14)
        }
    
    // MARK: - Properties
    static let identifier = "PoseFeedFilterCell"
    
    // MARK: - Functions
    
    func bind(to viewModel: PoseFeedFilterCellViewModel) {
        viewModel.title.bind(to: label.rx.text).disposed(by: disposeBag)
        
        viewModel.isSelected.asDriver()
            .drive(onNext: { [unowned self] in
                if $0 {
                    self.label.textColor = .mainVioletDark
                    self.backgroundColor = .violet100
                } else {
                    self.label.textColor = .textSecondary
                    self.backgroundColor = .bgSubWhite
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func render() {
        self.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.equalTo(self).inset(8)
            make.leading.trailing.equalTo(self).inset(12)
        }
    }
    
    override func configUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = .bgSubWhite
    }
}
