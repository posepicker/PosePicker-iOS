//
//  DefaultPageViewCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/26/24.
//

import UIKit
import RxSwift

class DefaultPageViewCoordinator: PageViewCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var pageViewController: UIPageViewController
    var commonViewController: CommonViewController
    var type: CoordinatorType { .pageview }
    
    var controllers: [UINavigationController] = []
    
    private let tooltip = ToolTip()
        .then {
            $0.layer.zPosition = 1000
            $0.isHidden = true
        }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.commonViewController = CommonViewController(pageViewController: pageViewController)
        self.commonViewController.viewModel = CommonViewModel(
            coordinator: self,
            commonUseCase: DefaultCommonUseCase(
                userRepository: DefaultUserRepository(
                    networkService: DefaultNetworkService(),
                    keychainService: DefaultKeychainService()
                )
            )
        )
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    /// 1. 코디네이터 시작과 동시에 start메서드 호출
    /// 2. createPageViewNavigationController 메서드 호출 -> pageViewController 서브뷰 배열 리턴
    ///     2-1. PageViewType에 맞게 UINavigationController에 뷰 푸시 & start
    func start() {
        let pages: [PageViewType] = [.posepick, .posetalk, .posefeed, .mypose]
        controllers = pages.map({
            self.createPageViewNavigationController(of: $0)
        })
        self.configurePageViewController(with: controllers)
        self.setToolTipUI()
        
        // 뷰 강제 로드시키기
//        self.setSelectedIndex(2)
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
        let mypageCoordinator = DefaultMyPageCoordinator(self.navigationController)
        mypageCoordinator.loginDelegate = self
        self.childCoordinators.append(mypageCoordinator)
        mypageCoordinator.start()
    }
    
    func pushBookmarkPage() -> Observable<LoginPopUpView.SocialLogin> {
        if UserDefaults.standard.bool(forKey: K.SocialLogin.isLoggedIn) {
            return .empty()
        } else {
            return showLoginFlow()
        }
    }
    
    func dismissLoginPopUp() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.setSelectedIndex(0)
        }
    }
    
    // 애플 or 카카오 탭 여부 확인
    func showLoginFlow() -> Observable<LoginPopUpView.SocialLogin> {
        let popupVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        guard let popupView = popupVC.popUpView as? LoginPopUpView else { return .empty() }
        self.navigationController.present(popupVC, animated: true)
        
        return popupView.socialLogin
    }
    
    func removeMyPoseContents() {
        if let myposeCoordinator = self.findCoordinator(type: .mypose) as? MyPoseCoordinator {
            print("REMOVEMYPOSECONTENTS!")
            myposeCoordinator.removeAllContents()
        }
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
            posetalkCoordinator.tooltipDelegate = self
            self.childCoordinators.append(posetalkCoordinator)
            posetalkCoordinator.start()
        case .posefeed:
            let posefeedCoordinator = DefaultPoseFeedCoordinator(pageviewNavigationController)
            posefeedCoordinator.loginDelegate = self
            self.childCoordinators.append(posefeedCoordinator)
            posefeedCoordinator.start()
        case .mypose:
            let myPoseCoordinator = DefaultMyPoseCoordinator(pageviewNavigationController)
            myPoseCoordinator.pageMoveDelegate = self
            if let posefeedCoordinator = self.findCoordinator(type: .posefeed) as? DefaultPoseFeedCoordinator {
                myPoseCoordinator.bookmarkBindingDelegate = posefeedCoordinator
            }
            self.childCoordinators.append(myPoseCoordinator)
            myPoseCoordinator.start()
            
            // 포즈피드 코디네이터의 북마크 탭 델리게이트 마이포즈에 연결
            let posefeedCoordinator = findCoordinator(type: .posefeed) as? PoseFeedCoordinator
            posefeedCoordinator?.bookmarkContentsUpdatedDelegate = myPoseCoordinator
        default:
            break
        }
    }
    
    private func setToolTipUI() {
        self.commonViewController.view.addSubview(self.tooltip)
        
        let segmentHeight = self.commonViewController.segmentControl.frame.height
        let headerHeight: CGFloat = UIScreen.main.isWiderThan375pt ? 38 : 28
        self.tooltip.snp.makeConstraints { make in
            make.leading.equalTo(UIScreen.main.isWiderThan375pt ? 76 : 66)
            make.width.equalTo(UIScreen.main.isWiderThan375pt ? 230 : 210)
            make.height.equalTo(UIScreen.main.isWiderThan375pt ? 80 : 68)
            make.top.equalTo(self.commonViewController.view.safeAreaLayoutGuide.snp.top).offset(segmentHeight + headerHeight)
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

extension DefaultPageViewCoordinator: CoordinatorLoginDelegate {
    func coordinatorLoginRequested(childCoordinator: any Coordinator) -> Observable<LoginPopUpView.SocialLogin> {
        if childCoordinator.type == .posefeed ||
           childCoordinator.type == .mypage {
            return showLoginFlow()
        } else {
            return .empty()
        }
    }
    
    func coordinatorLoginCompleted(childCoordinator: any Coordinator) {
        if childCoordinator.type == .posefeed ||
           childCoordinator.type == .mypage {
            self.dismissLoginPopUp()
            setSelectedIndex(0)
            if let posefeedCoordinator = self.findCoordinator(type: .posefeed) as? DefaultPoseFeedCoordinator {
                
                // 로그아웃 될때 마이포즈 화면 지우기
                if !UserDefaults.standard.bool(forKey: K.SocialLogin.isLoggedIn) {
                    KeychainManager.shared.removeAll()
                    
                    if let myposeCoordinator = self.findCoordinator(type: .mypose) as? DefaultMyPoseCoordinator {
                        myposeCoordinator.removeAllContents()
                    }
                } else {
                    if let myposeCoordinator = self.findCoordinator(type: .mypose) as? DefaultMyPoseCoordinator {
                        myposeCoordinator.refreshBookmark()
                        myposeCoordinator.refreshPoseCount()
                    }
                }
                commonViewController.segmentControl.rx.selectedSegmentIndex.onNext(0)
                posefeedCoordinator.posefeedViewController.viewDidLoadEvent.onNext(())
            }
        }
    }
}

extension DefaultPageViewCoordinator: CoordinatorTooltipDelegate {
    func coordinatorToggleTooltip(childCoordinator: any Coordinator) {
        tooltip.isHidden.toggle()
    }
    
    func coordinatorShowTooltip(childCoordinator: any Coordinator) {
        tooltip.isHidden = false
    }
    
    func coordinatorHideTooltip(childCoordinator: any Coordinator) {
        tooltip.isHidden = true
    }
}

extension DefaultPageViewCoordinator: CoordinatorPageMoveDelegate {
    func coordinatorMoveTo(pageType: PageViewType) {
        switch pageType {
        case .posepick:
            setSelectedIndex(0)
            self.commonViewController.segmentControl.rx.value.onNext(0)
        case .posetalk:
            setSelectedIndex(1)
            self.commonViewController.segmentControl.rx.value.onNext(1)
        case .posefeed:
            setSelectedIndex(2)
            self.commonViewController.segmentControl.rx.value.onNext(2)
        case .mypose:
            setSelectedIndex(3)
            self.commonViewController.segmentControl.rx.value.onNext(3)
        default:
            break
        }
    }
}
