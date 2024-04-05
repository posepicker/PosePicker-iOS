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
    
    var feedContents = BehaviorRelay<[Section<PoseFeedPhotoCellViewModel>]>(value: [])
    var filterSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    var recommendSectionContentSizes = BehaviorRelay<[CGSize]>(value: [])
    var isLastPage = BehaviorRelay<Bool>(value: false)
    var contentLoaded = PublishSubject<Void>()
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) {
        self.posefeedRepository
            .fetchFeedContents(peopleCount: peopleCount, frameCount: frameCount, filterTags: filterTags, pageNumber: pageNumber)
            .withUnretained(self)
            .subscribe(onNext: { (owner, sectionItems) in
                owner.contentLoaded.onNext(())
                if pageNumber == 0 { owner.feedContents.accept(sectionItems) }
                else {
                    var contents = owner.feedContents.value
                    contents[0].items += sectionItems[0].items
                    contents[1].items += sectionItems[1].items
                    owner.feedContents.accept(contents)
                }
                
                owner.checkIsLastPage() // 포즈피드 데이터 업데이트 이후 페이지 마지막 여부 업데이트
                
                // 필터링 섹션 이미지 사이즈
                sectionItems[0].items.forEach { viewModel in
                    guard let image = viewModel.image.value else { return }
                    let newSizeImage = owner.newSizeImageWidthDownloadedResource(image: image)
                    viewModel.image.accept(newSizeImage)
                    owner.filterSectionContentSizes.accept(
                        owner.filterSectionContentSizes.value + [newSizeImage.size]
                    )
                }
                
                // 추천 섹션 이미지 사이즈
                sectionItems[1].items.forEach { viewModel in
                    guard let image = viewModel.image.value else { return }
                    let newSizeImage = owner.newSizeImageWidthDownloadedResource(image: image)
                    viewModel.image.accept(newSizeImage)
                    owner.recommendSectionContentSizes.accept(
                        owner.recommendSectionContentSizes.value + [newSizeImage.size]
                    )
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 필터링 & 추천 둘다 마지막 페이지면 무한스크롤 더 이상 호출할 필요 없음
    private func checkIsLastPage() {
        Observable.combineLatest(
            self.posefeedRepository.isLastFilteredContents(),
            self.posefeedRepository.isLastRecommendContents()
        )
        .subscribe(onNext: { [weak self] (isLastFilteredContents, isLastRecommendedContents) in
            self?.isLastPage.accept(isLastFilteredContents && isLastRecommendedContents)
        })
        .disposed(by: disposeBag)
    }
    
    private func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
}
