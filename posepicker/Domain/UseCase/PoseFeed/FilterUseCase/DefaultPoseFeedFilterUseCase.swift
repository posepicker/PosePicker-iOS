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
    
    var tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [
        .init(title: "친구"),
        .init(title: "커플"),
        .init(title: "가족"),
        .init(title: "동료"),
        .init(title: "재미"),
        .init(title: "자연스러움"),
        .init(title: "유행"),
        .init(title: "유명인 프레임"),
        .init(title: "소품")
    ])
}
