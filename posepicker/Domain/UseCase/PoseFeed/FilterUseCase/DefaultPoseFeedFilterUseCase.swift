//
//  DefaultPoseFeedFilterUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultPoseFeedFilterUseCase: PoseFeedFilterUseCase {
    private var disposeBag = DisposeBag()
    
    var peopleCount = BehaviorRelay<Int>(value: 0)
    var frameCount = BehaviorRelay<Int>(value: 0)
    
    var tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [
        .init(title: "친구"),
        .init(title: "커플"),
        .init(title: "가족"),
        .init(title: "동료"),
        .init(title: "재미"),
        .init(title: "자연스러움"),
        .init(title: "유행"),
        .init(title: "유명프레임"),
        .init(title: "소품")
    ])
    
    func selectItem(title: String) {
        let tagItemsValue = tagItems.value
        if let index = tagItemsValue.firstIndex(where: {
            $0.title.value == title
        }) {
            tagItemsValue[index].isSelected.accept(!tagItemsValue[index].isSelected.value)
        }
    }
    
    func selectPeopleCount(value: Int) {
        peopleCount.accept(value)
    }
    
    func selectFrameCount(value: Int) {
        frameCount.accept(value)
    }
    
    func resetAllTags() {
        peopleCount.accept(0)
        frameCount.accept(0)
        
        let tagItemsValue = tagItems.value
        tagItemsValue.forEach {
            $0.isSelected.accept(false)
        }
        tagItems.accept(tagItemsValue)
    }
}
