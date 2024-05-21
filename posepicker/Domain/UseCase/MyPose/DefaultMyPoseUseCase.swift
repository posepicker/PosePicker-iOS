//
//  DefaultMyPoseUse.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultMyPoseUseCase: MyPoseUseCase {
    private var disposeBag = DisposeBag()
    private let myPoseRepository: MyPoseRepository
    
    init(myPoseRepository: MyPoseRepository) {
        self.myPoseRepository = myPoseRepository
    }
    
    var uploadedPoseCount = PublishSubject<String>()
    var savedPoseCount = PublishSubject<String>()
    
    var contentSizes = BehaviorRelay<[CGSize]>(value: [])
    var uploadedContents = BehaviorRelay<[BookmarkFeedCellViewModel]>(value: [])
    var contentLoaded = PublishSubject<Void>()
    var isLastPage = BehaviorRelay<Bool>(value: false)
    var bookmarkTaskCompleted = PublishSubject<Bool>()
    
    func fetchPoseCount() {
        myPoseRepository
            .fetchPoseCount()
            .subscribe(onNext: { [weak self] in
                self?.uploadedPoseCount.onNext("등록 \($0.uploadCount)")
                self?.savedPoseCount.onNext("저장 \($0.bookmarkCount)")
            })
            .disposed(by: disposeBag)
    }
    
    func fetchFeedContents(pageNumber: Int, pageSize: Int) {
        if pageNumber == 0 {
            contentSizes.accept([])
        }
        
        self.myPoseRepository
            .fetchUploadedContents(pageNumber: pageNumber, pageSize: pageSize)
            .withUnretained(self)
            .subscribe(onNext: {(owner, items) in
                owner.contentLoaded.onNext(())
                if pageNumber == 0 {
                    owner.uploadedContents.accept(items)
                } else {
                    var contents = owner.uploadedContents.value
                    contents += items
                    owner.uploadedContents.accept(contents)
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
        self.myPoseRepository.bookmarkContent(poseId: poseId, currentChecked: currentChecked)
            .subscribe(onNext: { [weak self] in
                self?.bookmarkTaskCompleted.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    func removeAllContents() {
        self.uploadedContents.accept([])
        self.isLastPage.accept(false)
        self.contentSizes.accept([])
    }
    
    /// 필터링 & 추천 둘다 마지막 페이지면 무한스크롤 더 이상 호출할 필요 없음
    private func checkIsLastPage() {
        self.myPoseRepository
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
