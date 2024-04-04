//
//  PoseFeedUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
import RxSwift
import RxRelay

protocol PoseFeedUseCase {
    // 필터 태그와 관련된 로직들은 코디네이터를 통해 얻어오는 것으로 구현
    // 뷰모델에서 유스케이스 데이터에 직접 접근하는 것은 권장되지 않음 (단일 책임원칙 위반)
    
    /// 피드 컨텐츠 & 사이즈 정보
    var feedContents: PublishSubject<[Section<PoseFeedPhotoCellViewModel>]> { get set }
    var filterSectionContentSizes: BehaviorRelay<[CGSize]> { get set }
    var recommendSectionContentSizes: BehaviorRelay<[CGSize]> { get set }
    
    func fetchFeedContents(peopleCount: String, frameCount: String, filterTags: [String], pageNumber: Int)
}
