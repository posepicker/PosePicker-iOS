//
//  PoseFeedFilterViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import Foundation
import RxCocoa
import RxSwift

class PoseFeedFilterViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let tagSelection: Observable<PoseFeedFilterCellViewModel>
    }
    
    struct Output {
        let tagItems: Driver<[PoseFeedFilterCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let tags = ["친구", "커플", "가족", "동료", "재미", "자연스러움", "유행", "유명인 프레임", "소품"]
        let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
        
        input.tagSelection
            .subscribe(onNext: {
                $0.isSelected.accept(!$0.isSelected.value)
            })
            .disposed(by: disposeBag)
        
        tagItems.accept(tags.map {
            PoseFeedFilterCellViewModel(title: $0)
        })
        
        return Output(tagItems: tagItems.asDriver())
    }
}
