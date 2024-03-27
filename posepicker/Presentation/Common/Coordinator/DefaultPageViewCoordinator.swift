//
//  DefaultPageViewCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/26/24.
//

import UIKit

class DefaultPageViewCoordinator: PageViewCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var pageViewController: UIPageViewController
    var commonViewController: CommonViewController
    var type: CoordinatorType { .pageview }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.pageViewController = UIPageViewController()
        self.commonViewController = CommonViewController()
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    /// 1. 코디네이터 시작과 동시에 start메서드 호출
    /// 2. createPageViewNavigationController 메서드 호출 -> pageViewController 서브뷰 배열 리턴
    ///     2-1. PageViewType에 맞게 UINavigationController에 뷰 푸시 & start
    func start() {
        let pages: [PageViewType] = [.posepick, .posetalk, .posefeed]
        let controllers: [UINavigationController] = pages.map({
            self.createPageViewNavigationController(of: $0)
        })
        self.configurePageViewController(with: controllers)
    }
    
    func selectPage(_ page: PageViewType) {
        
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = PageViewType(index: index),
              let currentIndex = currentPage()?.pageOrderNumber() else { return }
        self.pageViewController.setViewControllers(<#T##viewControllers: [UIViewController]?##[UIViewController]?#>, direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
    }
    
    /// currentPage 분기처리 -> 현재 뷰 컨트롤러 얻어와서 타입캐스팅
    /// 초기값 포즈톡으로 설정되어 있음
    func currentPage() -> PageViewType? {
//        pageViewController.viewControllers![0]
    }

    private func createPageViewNavigationController(of page: PageViewType) -> UINavigationController {
        let pageviewNavigationController = UINavigationController()
        pageviewNavigationController.setNavigationBarHidden(true, animated: false)
        self.startPageViewCoordinator(of: page, to: pageviewNavigationController)
        return pageviewNavigationController
    }
    
    private func configurePageViewController(with pageViewControllers: [UIViewController]) {
        self.commonViewController.pageViewController = pageViewController
        self.pageViewController.setViewControllers(pageViewControllers, direction: .forward, animated: true)
        self.navigationController.pushViewController(self.commonViewController, animated: true)
    }
    
    private func startPageViewCoordinator(of page: PageViewType, to pageviewNavigationController: UINavigationController) {
        switch page {
        case .posetalk:
            let posetalkCoordinator = DefaultPoseTalkCoordinator(pageviewNavigationController)
            posetalkCoordinator.finishDelegate = self
            self.childCoordinators.append(posetalkCoordinator)
            posetalkCoordinator.start()
        case .posepick:
            break
        case .posefeed:
            break
        default:
            break
        }
    }
}

extension DefaultPageViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: any Coordinator) {
        self.childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        
        if childCoordinator.type == .pageview {
            navigationController.viewControllers.removeAll()
        } else if childCoordinator.type == .mypage {
            self.navigationController.viewControllers.removeAll()
            self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
    }
}
