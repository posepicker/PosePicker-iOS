//
//  MyPoseUseCase.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift

protocol MyPoseUseCase {
    var uploadedPoseCount: PublishSubject<String> { get set }
    var savedPoseCount: PublishSubject<String> { get set }
    
    func fetchPoseCount()
}
