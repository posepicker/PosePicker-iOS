//
//  MyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit
import RxRelay

protocol PoseUploadCoordinator: Coordinator {
    var pageViewController: UIPageViewController { get set }
    var currentIndexFromView: BehaviorRelay<Int> { get set } // 화면 전환으로 바뀐 인덱스를 세그먼트에 바인딩
    func pushGuideline()
    func presentImageLoadFailedPopup()
    func pushPoseUploadView(image: UIImage?)

    func selectPage(_ page: PoseUploadPages)
    func setSelectedIndex(_ index: Int)
    func currentPage() -> PoseUploadPages?
    func viewControllerBefore() -> UIViewController?
    func viewControllerAfter() -> UIViewController?
}
