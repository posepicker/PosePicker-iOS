//
//  FilterUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import Foundation
import RxRelay

protocol PoseFeedFilterUseCase {
    var tagItems: BehaviorRelay<[PoseFeedFilterCellViewModel]> { get set }
    
    func selectItem(title: String)
}
