//
//  DefaultPoseFeedUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/3/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultPoseFeedUseCase: PoseFeedUseCase {
    
    private var disposeBag = DisposeBag()
    private let posefeedRepository: PoseFeedRepository
    
    init(posefeedRepository: PoseFeedRepository) {
        self.posefeedRepository = posefeedRepository
    }
    
    var feedContents = PublishSubject<[Section<PoseFeedPhotoCellViewModel>]>()
    var filterSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    var recommendSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) {
        
        self.posefeedRepository
            .fetchFeedContents(peopleCount: peopleCount, frameCount: frameCount, filterTags: filterTags, pageNumber: pageNumber)
            .subscribe(onNext: { [weak self] sectionItems in
                self?.feedContents.onNext(sectionItems)
                
                // 필터링 섹션 이미지 사이즈
                sectionItems[0].items.forEach { viewModel in
                    guard let image = viewModel.image.value,
                          let self = self else { return }
                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                    viewModel.image.accept(newSizeImage)
                    self.filterSectionContentSizes.accept(
                        self.filterSectionContentSizes.value + [newSizeImage.size]
                    )
                }
                
                // 추천 섹션 이미지 사이즈
                sectionItems[1].items.forEach { viewModel in
                    guard let image = viewModel.image.value,
                          let self = self else { return }
                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                    viewModel.image.accept(newSizeImage)
                    self.recommendSectionContentSizes.accept(
                        self.recommendSectionContentSizes.value + [newSizeImage.size]
                    )
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
}
