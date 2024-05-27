//
//  MockPageviewCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/3/24.
//

import UIKit
import RxSwift
@testable import posepicker

final class MockPageViewCoordinator: PageViewCoordinator {
    func showLoginFlow() -> Observable<posepicker.LoginPopUpView.SocialLogin> {
        return .empty()
    }
    
    func removeMyPoseContents() {
        
    }
    
    func pushBookmarkPage() -> Observable<posepicker.LoginPopUpView.SocialLogin> {
        return .empty()
    }
    
    func dismissLoginPopUp() {
        return
    }
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var pageViewController: UIPageViewController
    var commonViewController: CommonViewController
    var type: CoordinatorType { .pageview }
    
    var controllers: [UINavigationController] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.commonViewController = CommonViewController(pageViewController: pageViewController)
        self.commonViewController.viewModel = CommonViewModel(
            coordinator: self,
            commonUseCase: MockCommonUseCase()
        )
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    /// 1. 코디네이터 시작과 동시에 start메서드 호출
    /// 2. createPageViewNavigationController 메서드 호출 -> pageViewController 서브뷰 배열 리턴
    ///     2-1. PageViewType에 맞게 UINavigationController에 뷰 푸시 & start
    func start() {
        let pages: [PageViewType] = [.posepick, .posetalk, .posefeed]
        controllers = pages.map({
            self.createPageViewNavigationController(of: $0)
        })
        self.configurePageViewController(with: controllers)
    }
    
    func selectPage(_ page: PageViewType) {
        guard let currentIndex = currentPage()?.pageOrderNumber() else { return }
        
        self.pageViewController.setViewControllers([controllers[page.pageOrderNumber()]], direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = PageViewType(index: index),
              let currentIndex = currentPage()?.pageOrderNumber() else { return }
        
        self.pageViewController.setViewControllers([controllers[page.pageOrderNumber()]], direction: currentIndex <= page.pageOrderNumber() ? .forward : .reverse, animated: true)
    }
    
    /// currentPage 분기처리 -> 현재 뷰 컨트롤러 얻어와서 타입캐스팅
    /// 초기값 포즈톡으로 설정되어 있음
    func currentPage() -> PageViewType? {
        guard let navigationController = pageViewController.viewControllers?.first as? UINavigationController,
              let viewController = navigationController.viewControllers.first,
              let page = PageViewType(viewController) else { return .posepick }
        
        return page
    }
    
    func viewControllerBefore() -> UIViewController? {
        guard let currentIndex = currentPage()?.pageOrderNumber() else { return nil }
        if currentIndex == 0 {
            return nil
        }
        
        return controllers[currentIndex - 1]
    }
    
    func viewControllerAfter() -> UIViewController? {
        guard let currentIndex = currentPage()?.pageOrderNumber() else { return nil }
        if currentIndex == controllers.count - 1 {
            return nil
        }
        return controllers[currentIndex + 1]
    }
    
    func pushMyPage() {
        let mypageViewController = MyPageViewController()
        self.navigationController.pushViewController(mypageViewController, animated: true)
    }

    private func createPageViewNavigationController(of page: PageViewType) -> UINavigationController {
        let pageviewNavigationController = UINavigationController()
        pageviewNavigationController.setNavigationBarHidden(true, animated: false)
        self.startPageViewCoordinator(of: page, to: pageviewNavigationController)
        return pageviewNavigationController
    }
    
    private func configurePageViewController(with pageViewControllers: [UIViewController]) {
        self.pageViewController.delegate = commonViewController
        self.pageViewController.dataSource = commonViewController
        self.pageViewController.setViewControllers([pageViewControllers[0]], direction: .forward, animated: true)
        self.navigationController.pushViewController(self.commonViewController, animated: true)
    }
    
    private func startPageViewCoordinator(of page: PageViewType, to pageviewNavigationController: UINavigationController) {
        switch page {
        case .posepick:
            let posepickCoordinator = DefaultPosePickCoordinator(pageviewNavigationController)
            posepickCoordinator.finishDelegate = self
            self.childCoordinators.append(posepickCoordinator)
            posepickCoordinator.start()
        case .posetalk:
            let posetalkCoordinator = DefaultPoseTalkCoordinator(pageviewNavigationController)
            posetalkCoordinator.finishDelegate = self
            self.childCoordinators.append(posetalkCoordinator)
            posetalkCoordinator.start()
        case .posefeed:
            let posefeedCoordinator = DefaultPoseFeedCoordinator(pageviewNavigationController)
            posefeedCoordinator.finishDelegate = self
            self.childCoordinators.append(posefeedCoordinator)
            posefeedCoordinator.start()
        default:
            break
        }
    }
}

extension MockPageViewCoordinator: CoordinatorFinishDelegate {
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
