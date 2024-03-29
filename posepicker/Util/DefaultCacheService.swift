//
//  DefaultCacheService.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import Foundation
import Kingfisher

final class DefaultCacheService: CacheService {
    func cacheImage(imageKey: String) {
        ImageCache.default.retrieveImage(forKey: imageKey, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    
                }
            case .failure:
                return
            }
        }
        
//        ImageCache.default.retrieveImage(forKey: posepick.poseInfo.imageKey, options: nil) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let value):
//                if let image = value.image {
//                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
//                    
//                    isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
//                    
//                    let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
//                    viewModelObservable.accept(viewModelObservable.value + [viewModel])
//                } else {
//                    guard let url = URL(string: posepick.poseInfo.imageKey) else { return }
//                    KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
//                        switch downloadResult {
//                        case .success(let downloadImage):
//                            let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
//                            
//                            isFilterSection ? self.filteredContentSizes.accept(self.filteredContentSizes.value + [newSizeImage.size]) : self.recommendedContentsSizes.accept(self.recommendedContentsSizes.value + [newSizeImage.size])
//                            
////                                isFilterSection ? filterContentSizeObservable.accept(filterContentSizeObservable.value + [newSizeImage.size]) : recommendContentSizeObservable.accept(recommendContentSizeObservable.value + [newSizeImage.size])
//                            
////                                isFilterSection ? self.filterContentsLoadCompleteTrigger.onNext(true) : self.filterContentsLoadCompleteTrigger.onNext(false)
//                            
//                            let viewModel = PoseFeedPhotoCellViewModel(image: newSizeImage, poseId: posepick.poseInfo.poseId, bookmarkCheck: posepick.poseInfo.bookmarkCheck ?? false)
//                            viewModelObservable.accept(viewModelObservable.value + [viewModel])
//                        case .failure:
//                            return
//                        }
//                    }
//                }
//            case .failure:
//                return
//            }
//        }
    }
    
    func downloadImage() {
        <#code#>
    }
}
