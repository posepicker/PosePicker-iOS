//
//  PoseTalkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation
import RxSwift
import RxRelay

protocol PoseTalkUseCase {
    var poseWord: BehaviorRelay<String?> { get set }
    var isLoading: BehaviorRelay<Bool> { get set }
    
    func fetchPoseTalk()
}
