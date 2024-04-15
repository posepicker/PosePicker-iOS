//
//  PoseDetailTagCell.swift
//  posepicker
//
//  Created by Jun on 2023/11/18.
//

import UIKit

class PoseDetailTagCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    
    let label = UILabel()
        .then {
            $0.textColor = .textSecondary
            $0.font = .pretendard(.medium, ofSize: 14)
        }
    
    // MARK: - Properties
    
    static let identifier = "PoseDetailTagCell"
    
    // MARK: - Functions

    func bind(to viewModel: PoseDetailTagCellViewModel) {
        viewModel.title.bind(to: label.rx.text).disposed(by: disposeBag)
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
