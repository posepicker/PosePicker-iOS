//
//  PoseUploadUseCase.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift

protocol PoseUploadUseCase {
    var uploadCompletedEvent: PublishSubject<PoseInfo> { get set }
    
    func savePose(
        image: UIImage?,
        frameCount: String,
        peopleCount: String,
        source: String,
        sourceUrl: String,
        tag: String
    )
}
