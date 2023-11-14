//
//  PoseFeedSection.swift
//  posepicker
//
//  Created by Jun on 2023/11/14.
//

import UIKit
import RxDataSources

struct PoseSection {
    var header: String
    var items: [Item]
}

extension PoseSection: SectionModelType {
    typealias Item = PoseFeedPhotoCellViewModel
    
    var identity: String {
        return header
    }
    
    init(original: PoseSection, items: [PoseFeedPhotoCellViewModel]) {
        self = original
        self.items = items
    }
}

extension PoseFeedPhotoCellViewModel: IdentifiableType, Equatable {
    static func == (lhs: PoseFeedPhotoCellViewModel, rhs: PoseFeedPhotoCellViewModel) -> Bool {
        return lhs.imageKey.value == rhs.imageKey.value
    }
    
    
    var identity: String {
        return imageKey.value
    }
}
