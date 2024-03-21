//
//  MyPoseCustomTagCell.swift
//  posepicker
//
//  Created by 박경준 on 2/29/24.
//

import UIKit
import RxSwift

class MyPoseCustomTagCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    let label = UILabel()
        .then {
            $0.textColor = .mainVioletDark
            $0.font = .subTitle2
        }
    
    let closeImageView = UIImageView(image: ImageLiteral.imgClose20.withTintColor(.mainVioletLight, renderingMode: .alwaysOriginal))
    
    // MARK: - Properties
    static let identifier = "MyPoseCustomTagCell"
    
    // MARK: - Life Cycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Functions
    
    func bind(to viewModel: PoseFeedFilterCellViewModel) {
        viewModel.title.bind(to: label.rx.text).disposed(by: disposeBag)
    }
    
    override func render() {
        self.addSubViews([label, closeImageView])
        
        label.snp.makeConstraints { make in
            make.top.bottom.equalTo(self).inset(7.5)
            make.leading.equalTo(self).inset(12)
        }
        
        closeImageView.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(5)
            make.trailing.equalTo(self).offset(-12)
            make.centerY.equalTo(label)
            make.width.height.equalTo(14)
        }
    }
    
    override func configUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = .gray100
    }
}
