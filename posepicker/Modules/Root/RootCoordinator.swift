//
//  RootCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

enum RootPage {
    case posepick
    case posetalk
    case posefeed
    case bookmark
    case myPage
    
    func pageTitleValue() -> String {
        switch self {
        case .posepick:
            return "포즈픽"
        case .posetalk:
            return "포즈톡"
        case .posefeed:
            return "포즈피드"
        case .bookmark:
            return "북마크"
        case .myPage:
            return ""
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .posepick:
            return 0
        case .posetalk:
            return 1
        case .posefeed:
            return 2
        case .bookmark:
            return 3
        case .myPage:
            return 4
        }
    }
}

/// 뷰 컨트롤러에서 사용하는 객체들은 마련만 해두고 화면 흐름 제어만 코디네이터에서 처리
/// 화면 흐름의 요청은 currentPage 데이터 세팅 이후에만 이루어진다
/// selectedIndex 반응형 처리도 currentPage 세팅을 통해 화면흐름 제어
class RootCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    lazy var rootViewController = RootViewController(viewModel: RootViewModel() ,coordinator: self)
    lazy var posefeedCoordinator = PoseFeedCoordinator(navigationController: self.navigationController)
    
    // MARK: - Initialization
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Functions
    
    func start() {
        rootViewController.pageViewController.setViewControllers([rootViewController.viewControllers[0]], direction: .forward, animated: true)
        
        navigationController.viewControllers = [rootViewController]
    }
    
    /// UIViewController 참조를 통한 이동
    func moveWithViewController(viewController: [UIViewController], direction: UIPageViewController.NavigationDirection, pageNumber: Int) {
        rootViewController.pageViewController.setViewControllers(viewController, direction: direction, animated: true)
        rootViewController.segmentControl.rx.selectedSegmentIndex.onNext(pageNumber)
        rootViewController.segmentControl.updateUnderlineViewWidth()
        rootViewController.segmentControl.moveUnderlineView()
    }
    
    /// RootPage 열거형 참조를 통한 이동
    func moveWithPage(page: RootPage, direction: UIPageViewController.NavigationDirection) {
        let viewController = rootViewController.getNavigationController(page)
        moveWithViewController(viewController: [viewController], direction: direction, pageNumber: page.pageOrderNumber())
    }
    
    /// segmentControl selectedIndex값 변경에 따른 화면흐름 제어
    func moveWithSegment(pageNumber: Int) {
        rootViewController.segmentControl.rx.selectedSegmentIndex.onNext(pageNumber)
        rootViewController.segmentControl.updateUnderlineViewWidth()
        rootViewController.segmentControl.moveUnderlineView()
    }
    
    /// 북마크 페이지 푸시
    func push(page: RootPage) {
        switch page {
        case .myPage:
            self.navigationController.pushViewController(MyPageViewController(viewModel: MyPageViewModel(), coordinator: self), animated: true)
        case .bookmark:
            self.navigationController.pushViewController(BookMarkViewController(viewModel: BookMarkViewModel(), coordinator: self), animated: true)
        default:
            break
        }
    }
}
