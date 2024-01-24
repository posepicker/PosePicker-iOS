//
//  RegisteredFilterCell.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/28.
//

import UIKit
import RxSwift

/// 필터링 모달 뷰에서 등록된 필터 컬렉션뷰 셀
class RegisteredFilterCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    let title = UILabel()
        .then {
            $0.textColor = .textSecondary
            $0.font = .pretendard(.medium, ofSize: 14)
        }
    
    let deleteImageView = UIImageView(image: ImageLiteral.imgClose12.withRenderingMode(.alwaysOriginal).withTintColor(.iconDisabled).resize(to: CGSize(width: 12, height: 12)))
    
    // MARK: - Properties
    static let identifier = "RegisteredFilterCell"
    
    // MARK: - Life Cycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Functions
    
    func bind(to viewModel: RegisteredFilterCellViewModel) {
        viewModel.title.bind(to: self.title.rx.text).disposed(by: disposeBag)
    }
    
    override func configUI() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        self.backgroundColor = .bgSubWhite
    }
    
    override func render() {
        self.addSubViews([title, deleteImageView])
        
        title.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(12)
            make.top.bottom.equalTo(self).inset(7.5)
        }
        
        deleteImageView.snp.makeConstraints { make in
            make.leading.equalTo(title.snp.trailing).offset(6)
            make.trailing.equalTo(self).offset(-12)
            make.centerY.equalTo(title)
            make.width.height.equalTo(12)
        }
    }
}
