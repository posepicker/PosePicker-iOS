//
//  BookmarkSection.swift
//  posepicker
//
//  Created by 박경준 on 12/12/23.
//

import UIKit
import RxDataSources

struct BookmarkSection {
    var header: String
    var items: [Item]
}

extension BookmarkSection: SectionModelType {
    typealias Item = BookmarkFeedCellViewModel
    
    init(original: BookmarkSection, items: [BookmarkFeedCellViewModel]) {
        self = original
        self.items = items
    }
}

