//
//  PageViewCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/22/24.
//

import UIKit

protocol PageViewCoordinator: Coordinator {
    var pageViewController: UIPageViewController { get set }
    func selectPage(_ page: PageViewType)
    func setSelectedIndex(_ index: Int)
    func currentPage() -> PageViewType?
    func viewControllerBefore() -> UIViewController?
    func viewControllerAfter() -> UIViewController?
    func pushMyPage()
}
