//
//  PoseFeedSection.swift
//  posepicker
//
//  Created by Jun on 2023/11/14.
//

import UIKit
import RxDataSources

struct Section<T> {
    var header: String
    var items: [Item]
}

extension Section: SectionModelType {
    typealias Item = T
    
    init(original: Section, items: [T]) {
        self = original
        self.items = items
    }
}
