//
//  BookmarkRepository.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation
import RxSwift

protocol BookmarkRepository {
    func fetchBookmarkContents(pageNumber: Int, pageSize: Int) -> Observable<[BookmarkFeedCellViewModel]>
    func isLastContents() -> Observable<Bool>
}
