//
//  PoseDetailUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/7/24.
//

import UIKit
import RxSwift
import RxRelay

protocol PoseDetailUseCase {
    var image: BehaviorRelay<UIImage?> { get  set }
    var tagItems: BehaviorRelay<[String]> { get set }
    var sourceUrl: BehaviorRelay<String> { get set }   // SNS URL
    var source: BehaviorRelay<String> { get set }      // SNS 아이디
    var bookmarkTaskCompleted: PublishSubject<Bool> { get set }
    var contentLoaded: PublishSubject<Void> { get set }
    
    func getPoseInfo()
    func bookmarkContent(poseId: Int, currentChecked: Bool)
}
