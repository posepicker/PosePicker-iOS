//
//  BookmarkRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift

protocol BookmarkRepository {
    func fetchBookmarkContents() -> Observable<[BookmarkFeedCellViewModel]>
}
