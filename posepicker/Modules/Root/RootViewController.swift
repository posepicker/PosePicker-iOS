//
//  RootViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class RootViewController: BaseViewController {
    
    // MARK: - Subviews
    
    lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        .then {
            let pages: [RootPage] = [.posepick, .posetok, .posefeed, .bookmark, .myPage].sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
            viewControllers = pages.map { getNavigationController($0) }
            $0.setViewControllers([viewControllers[1]], direction: .forward, animated: true)
            $0.dataSource = self
            $0.delegate = self
        }
    
    // MARK: - Properties
    var viewControllers: [UIViewController] = []
    
    var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [viewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    // MARK: - Initialization
    
    // MARK: - Functions
    override func render() {
        view.addSubViews([pageViewController.view])
        
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func getNavigationController(_ page: RootPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)
        
        switch page {
        case .posepick:
            let posePickerVC = PosePickViewController()
            navController.pushViewController(posePickerVC, animated: true)
        case .posetok:
            let poseTokVC = PoseTokViewController()
            navController.pushViewController(poseTokVC, animated: true)
        case .posefeed:
            let poseFeedVC = PoseFeedViewController()
            navController.pushViewController(poseFeedVC, animated: true)
        case .bookmark:
            let bookmarkVC = BookMarkViewController()
            navController.pushViewController(bookmarkVC, animated: true)
        case .myPage:
            let myPageVC = MyPageViewController()
            navController.pushViewController(myPageVC, animated: true)
        }
        
        return navController
    }
    
    
}

extension RootViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        
        guard let navigationVC = pageViewController.viewControllers?[0] as? UINavigationController,
              let index = self.viewControllers.firstIndex(of: navigationVC) else { return }
        self.currentPage = index
//        self.segmentedControl.selectedSegmentIndex = index
    }
}

extension RootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let navigationVC = viewController as? UINavigationController,
              let index = self.viewControllers.firstIndex(of: navigationVC),
              index - 1 >= 0 else {
             return nil
        }
        return self.viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let navigationVC = viewController as? UINavigationController,
              let index = self.viewControllers.firstIndex(of: navigationVC),
              index + 1 < self.viewControllers.count else {
            return nil
        }
        return self.viewControllers[index + 1]
    }
}
