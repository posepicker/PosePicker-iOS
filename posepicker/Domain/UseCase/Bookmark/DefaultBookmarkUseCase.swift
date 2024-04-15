//
//  DefaultBookmarkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultBookmarkUseCase: BookmarkUseCase {
    
    private var disposeBag = DisposeBag()
    private let bookmarkRepository: BookmarkRepository
    
    var contentSizes = BehaviorRelay<[CGSize]>(value: [])
    var bookmarkContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
    var contentLoaded = PublishSubject<Void>()
    var isLastPage = BehaviorRelay<Bool>(value: false)
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    init(bookmarkRepository: BookmarkRepository) {
        self.bookmarkRepository = bookmarkRepository
    }
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int) {
        if pageNumber == 0 {
            contentSizes.accept([])
        }
        
        self.bookmarkRepository
            .fetchBookmarkContents(pageNumber: pageNumber, pageSize: pageSize)
            .withUnretained(self)
            .subscribe(onNext: {(owner, items) in
                owner.contentLoaded.onNext(())
                if pageNumber == 0 {
                    owner.bookmarkContents.accept(items)
                } else {
                    var contents = owner.bookmarkContents.value
                    contents += items
                    owner.bookmarkContents.accept(contents)
                }
                
                owner.checkIsLastPage()
                
                items.forEach { viewModel in
                    guard let image = viewModel.image.value else { return }
                    let newSizeImage = owner.newSizeImageWidthDownloadedResource(image: image)
                    viewModel.image.accept(newSizeImage)
                    owner.contentSizes.accept(owner.contentSizes.value + [newSizeImage.size])
                }
        })
            .disposed(by: disposeBag)
    }
    
    func bookmarkContent(poseId: Int, currentChecked: Bool) {
        self.bookmarkRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    /// 필터링 & 추천 둘다 마지막 페이지면 무한스크롤 더 이상 호출할 필요 없음
    private func checkIsLastPage() {
        self.bookmarkRepository
            .isLastContents()
            .subscribe(onNext: { [weak self] in
                self?.isLastPage.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = (UIScreen.main.bounds.width - 56) / 2
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
}
