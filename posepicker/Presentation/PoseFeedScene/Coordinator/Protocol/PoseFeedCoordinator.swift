//
//  PoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import Foundation
import RxSwift

protocol PoseFeedCoordinator: Coordinator {
    func presentFilterModal()
    func presentTagResetConfirmModal(disposeBag: DisposeBag) -> Observable<Bool>
}
