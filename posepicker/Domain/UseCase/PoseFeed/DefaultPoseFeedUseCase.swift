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
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int) {
        if pageNumber == 0 {
            filterSectionContentSizes.accept([])
            recommendSectionContentSizes.accept([])
        }
        
        Observable.combineLatest(
            self.posefeedRepository.isLastFilteredContents(),
            self.posefeedRepository.isLastRecommendContents()
        )
        .subscribe(onNext: { [weak self] (isLastFilteredContents, isLastRecommendedContents) in
            self?.isLastPage.accept(isLastFilteredContents && isLastRecommendedContents)
        })
        .disposed(by: disposeBag)
        
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
                
                // 필터링 섹션 이미지 사이즈
                sectionItems[0].items.forEach { viewModel in
                    owner.filterSectionContentSizes.accept(
                        owner.filterSectionContentSizes.value + [viewModel.size.value]
                    )
                }
                
                sectionItems[1].items.forEach { viewModel in
                    owner.recommendSectionContentSizes.accept(
                        owner.recommendSectionContentSizes.value + [viewModel.size.value]
                    )
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        self.posefeedRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
//    private func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
//        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
//        let newSizeImage = image.resize(newWidth: targetWidth)
//        return newSizeImage
//    }
}
