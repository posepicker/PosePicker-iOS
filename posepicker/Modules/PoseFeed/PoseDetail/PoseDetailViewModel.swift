//
//  PoseDetailViewModel.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit

import RxCocoa
import RxSwift
import Kingfisher

class PoseDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var poseDetailData: PosePick
    
    init(poseDetailData: PosePick) {
        self.poseDetailData = poseDetailData
    }
    
    struct Input {
        let imageSourceButtonTapped: ControlEvent<Void>
        let linkShareButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let imageSourceLink: Observable<URL?>
        let image: Observable<UIImage?>
        let popupPresent: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let imageSource = BehaviorRelay<URL?>(value: nil)
        let cacheImage = BehaviorRelay<UIImage?>(value: nil)
        let popupPresent = PublishSubject<Void>()
        
        /// 이미지 출처 - URL 전달
        input.imageSourceButtonTapped
            .subscribe(onNext: { [unowned self] in
                let url = URL(string: "https://" + self.poseDetailData.poseInfo.sourceUrl)
                imageSource.accept(url)
            })
            .disposed(by: disposeBag)
        
        /// 이미지 캐시처리
        ImageCache.default.retrieveImage(forKey: poseDetailData.poseInfo.imageKey, options: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if let image = value.image {
                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                    cacheImage.accept(newSizeImage)
                } else {
                    guard let url = URL(string: self.poseDetailData.poseInfo.imageKey) else { return }
                    KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                        switch downloadResult {
                        case .success(let downloadImage):
                            let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                            cacheImage.accept(newSizeImage)
                        case .failure:
                            return
                        }
                    }
                }
            case .failure:
                cacheImage.accept(nil)
            }
        }
        
        /// 링크 공유 버튼 탭
        input.linkShareButtonTapped
            .subscribe(onNext: { [unowned self] in
                UIPasteboard.general.string = "https://www.posepicker.site/detail/\(self.poseDetailData.poseInfo.poseId)"
                popupPresent.onNext(())
            })
            .disposed(by: disposeBag)
        
        return Output(imageSourceLink: imageSource.asObservable(), image: cacheImage.asObservable(), popupPresent: popupPresent.asDriver(onErrorJustReturn: ()))
    }
    
    /// 디자인 수치 기준으로 이미지 리사이징
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = UIScreen.main.bounds.width
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
}
