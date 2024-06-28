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
            $0.backgroundColor = .init(hex: "#F9F9FB")
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
    let dataRequestCancelTrigger = PublishSubject<Void>()
    private var downloadTask: DownloadTask?
    
    // MARK: - Life Cycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if imageView.image == nil {
            downloadTask?.cancel()
            print("imageURL: \(viewModel.imageURL.value)")
        }
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
        viewModel.imageURL.asDriver()
            .drive(onNext: { imageURL in
                print("imageURL: \(imageURL)")
                ImageCache.default.retrieveImage(forKey: imageURL) { [weak self] cacheResult in
                    switch cacheResult {
                    case .success(let value):
                        if let image = value.image {
                            self?.imageView.image = image
                        } else if let url = URL(string: imageURL) {
                            self?.downloadTask = KingfisherManager.shared.retrieveImage(with: url) { [weak self] downloadResult in
                                switch downloadResult {
                                case .success(let downloadedImage):
                                    self?.imageView.image = downloadedImage.image
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
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
