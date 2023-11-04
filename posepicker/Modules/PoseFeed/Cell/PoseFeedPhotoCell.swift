//
//  PoseFeedPhotoCell.swift
//  posepicker
//
//  Created by Jun on 2023/11/05.
//

import UIKit
import Kingfisher

import RxCocoa
import RxSwift

class PoseFeedPhotoCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    let imageView = UIImageView()
        .then {
            $0.contentMode = .scaleAspectFill
        }
    
    // MARK: - Properties
    static let identifier = "PoseFeedPhotoCell"
    
    // MARK: - Life Cycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Functions
    override func render() {
        self.addSubViews([imageView])
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo((UIScreen.main.bounds.width - 56) / 2)
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    func bind(to viewModel: PoseFeedPhotoCellViewModel) {
        viewModel.imageUrl.asDriver()
            .drive(onNext: { [unowned self] in
                self.imageView.kf.setImage(with: URL(string: $0))
            })
            .disposed(by: disposeBag)
    }
}
