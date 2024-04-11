//
//  MyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

protocol PoseUploadCoordinator: Coordinator {
    var pageViewController: UIPageViewController? { get set }
    func pushGuideline()
    func presentImageLoadFailedPopup()
    func pushPoseUploadView(image: UIImage?)

    func selectPage(_ page: PageViewType)
    func setSelectedIndex(_ index: Int)
    func currentPage() -> PageViewType?
    func viewControllerBefore() -> UIViewController?
    func viewControllerAfter() -> UIViewController?
}
