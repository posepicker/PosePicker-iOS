//
//  PoseFeedSection.swift
//  posepicker
//
//  Created by Jun on 2023/11/14.
//

import Foundation
import RxDataSources

struct PoseSection {
    var header: String
    var items: [Item]
}

extension PoseSection: SectionModelType {
    typealias Item = PoseFeedPhotoCellViewModel
    
    init(original: PoseSection, items: [PoseFeedPhotoCellViewModel]) {
        self = original
        self.items = items
    }
}
