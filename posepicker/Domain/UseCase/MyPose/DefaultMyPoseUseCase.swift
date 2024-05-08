//
//  DefaultMyPoseUse.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultMyPoseUseCase: MyPoseUseCase {
    private var disposeBag = DisposeBag()
    private let myPoseRepository: MyPoseRepository
    
    init(myPoseRepository: MyPoseRepository) {
        self.myPoseRepository = myPoseRepository
    }
}
