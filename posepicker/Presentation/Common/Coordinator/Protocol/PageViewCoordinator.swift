//
//  PageViewCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import UIKit
import RxSwift

protocol PageViewCoordinator: Coordinator {
    var pageViewController: UIPageViewController { get set }
    func setSelectedIndex(_ index: Int)
    func currentPage() -> PageViewType?
    func viewControllerBefore() -> UIViewController?
    func viewControllerAfter() -> UIViewController?
    func pushMyPage()
    func pushBookmarkPage() -> Observable<LoginPopUpView.SocialLogin>
    func dismissLoginPopUp()
    func showLoginFlow() -> Observable<LoginPopUpView.SocialLogin>
    func removeMyPoseContents()
}
