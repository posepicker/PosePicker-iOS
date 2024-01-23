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
import SkeletonView

class PoseFeedPhotoCell: BaseCollectionViewCell {
    
    // MARK: - Subviews
    let imageView = UIImageView()
        .then {
            $0.contentMode = .scaleAspectFill
        }
    
    let bookmarkButton = UIButton()
        .then {
            $0.setImage(ImageLiteral.imgBookmarkOff24.withTintColor(.iconWhite, renderingMode: .alwaysTemplate), for: .normal)
            $0.layer.cornerRadius = 18
            $0.clipsToBounds = true
            $0.backgroundColor = .dimmed30
        }
    
    // MARK: - Properties
    static let identifier = "PoseFeedPhotoCell"
    var viewModel: PoseFeedPhotoCellViewModel!
    
    // MARK: - Life Cycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bookmarkButton.setImage(nil, for: .normal)
        viewModel = nil
        disposeBag = DisposeBag()
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
    }
    
    func bind() {
        weak var viewModel: PoseFeedPhotoCellViewModel! = viewModel
        viewModel.image.asDriver()
            .drive(onNext: { [weak self] in
                if let image = $0 {
                    self?.imageView.image = image
                } else {
                    self?.imageView.backgroundColor = .gray100
                }
//                self?.imageView.image = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.bookmarkCheck.asDriver()
            .drive(onNext: { [weak self] bookmarkCheck in
                if bookmarkCheck {
                    self?.bookmarkButton.setImage(ImageLiteral.imgBookmarkFill24, for: .normal)
                } else {
                    self?.bookmarkButton.setImage(ImageLiteral.imgBookmarkOff24, for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
}
