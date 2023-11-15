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
    
    let bookmarkButton = UIButton()
        .then {
            $0.setImage(ImageLiteral.imgBookmarkOff24.withTintColor(.iconWhite, renderingMode: .alwaysOriginal), for: .normal)
            $0.layer.cornerRadius = 18
            $0.clipsToBounds = true
            $0.backgroundColor = .bgWhite.withAlphaComponent(0.38)
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
        self.addSubViews([imageView, bookmarkButton])
        
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(6)
            make.width.height.equalTo(36)
        }
    }
    
    override func configUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        
        bookmarkButton.rx.tap
            .asDriver()
            .drive(onNext: {
                print("TAP")
            })
            .disposed(by: disposeBag)
    }
    
    func bind(to viewModel: PoseFeedPhotoCellViewModel) {
        viewModel.image.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
}
