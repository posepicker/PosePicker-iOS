//
//  CoordinatorLoginDelegate.swift
//  posepicker
//
//  Created by 박경준 on 4/9/24.
//

import Foundation
import RxSwift

/// 코디네이터 동작이 모두 끝났을 때 다른 뷰로 즉각 이동하기 위한 동작
protocol CoordinatorLoginDelegate: AnyObject {
    func coordinatorLoginCompleted(childCoordinator: Coordinator)
    func coordinatorLoginRequested(childCoordinator: Coordinator) -> Observable<LoginPopUpView.SocialLogin>
}
