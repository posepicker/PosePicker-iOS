//
//  PoseTalkRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation
import RxSwift

protocol PoseTalkRepository {
    func fetchPoseWord() -> Observable<String?>
}
