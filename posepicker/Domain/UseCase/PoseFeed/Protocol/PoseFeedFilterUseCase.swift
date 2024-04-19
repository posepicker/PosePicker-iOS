//
//  FilterUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import Foundation
import RxRelay

protocol PoseFeedFilterUseCase {
    var peopleCount: BehaviorRelay<Int> { get set }
    var frameCount: BehaviorRelay<Int> { get set }
    var tagItems: BehaviorRelay<[PoseFeedFilterCellViewModel]> { get set }
    
    func selectItem(title: String)
    func selectPeopleCount(value: Int)
    func selectFrameCount(value: Int)
    func resetAllTags()
}
