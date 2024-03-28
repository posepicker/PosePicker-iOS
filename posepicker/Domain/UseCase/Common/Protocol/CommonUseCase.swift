//
//  CommonUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import Foundation
import RxSwift

protocol CommonUseCase {
    var poseWord: PublishSubject<String> { get set }
    
    func fetchPoseTalk()
}
