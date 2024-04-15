//
//  PosePickRepository.swift
//  posepicker
//
//  Created by 박경준 on 3/29/24.
//

import UIKit
import RxSwift

protocol PosePickRepository {
    func fetchPoseImage(peopleCount: Int) -> Observable<UIImage?>
}
