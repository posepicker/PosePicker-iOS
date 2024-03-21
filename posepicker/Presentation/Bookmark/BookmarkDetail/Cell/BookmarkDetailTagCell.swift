//
//  BookmarkDetailTagCell.swift
//  posepicker
//
//  Created by 박경준 on 12/13/23.
//

import UIKit

class BookmarkDetailTagCell: BaseCollectionViewCell {
    // MARK: - Subviews
    
    let label = UILabel()
        .then {
            $0.textColor = .textSecondary
            $0.font = .pretendard(.medium, ofSize: 14)
        }
    
    // MARK: - Properties
    
    static let identifier = "BookmarkDetailTagCell"
    
    // MARK: - Functions

    func bind(to viewModel: BookmarkDetailTagCellViewModel) {
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
