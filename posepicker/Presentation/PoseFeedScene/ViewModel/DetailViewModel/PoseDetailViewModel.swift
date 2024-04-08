//
//  PoseDetailViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import UIKit
import RxSwift
import RxRelay

final class PoseDetailViewModel {
    weak var coordinator: PoseFeedCoordinator?
    private var posefeedDetailUseCase: PoseFeedDetailUseCase
    private let bindViewModel: PoseFeedPhotoCellViewModel
    
    init(coordinator: PoseFeedCoordinator?, posefeedDetailUseCase: PoseFeedDetailUseCase, bindViewModel: PoseFeedPhotoCellViewModel) {
        self.coordinator = coordinator
        self.posefeedDetailUseCase = posefeedDetailUseCase
        self.bindViewModel = bindViewModel
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
        let tagItems = BehaviorRelay<[PoseDetailTagCellViewModel]>(value: [])
        let url = PublishRelay<String>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.posefeedDetailUseCase.getSourceURLFrom()
                self?.posefeedDetailUseCase.getTagsFromPoseInfo()
            })
            .disposed(by: disposeBag)
        
        self.posefeedDetailUseCase
            .tagItems
            .map { tags in
                tags.map { PoseDetailTagCellViewModel(title: $0)}
            }
            .subscribe(onNext: {
                output.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.posefeedDetailUseCase
            .sourceUrl
            .subscribe(onNext: {
                output.url.accept($0)
            })
            .disposed(by: disposeBag)
        
        output.image.accept(
            bindViewModel.image.value?.resize(newWidth: UIScreen.main.bounds.width)
        )
        
        return output
    }
}
