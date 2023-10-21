//
//  RootViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

import RxCocoa
import RxSwift

class RootViewController: BaseViewController {
    
    // MARK: - Subviews
    lazy var segmentedControl = UnderlineSegmentControl(items: ["포즈픽", "포즈톡", "포즈피드", "북마크"])
        .then {
//            $0.addTarget(self, action: #selector(changeCurrentPage(control:)), for: .valueChanged)
            $0.selectedSegmentTintColor = .mainViolet
            $0.selectedSegmentIndex = 0
        }
    
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
    
//    lazy var segmentedControl = UnderlineSegmentedControl(items: ["보관함", "채움함", "완료함"])
//        .then {
//            $0.addTarget(self, action: #selector(changeCurrentPage(control:)), for: .valueChanged)
//            $0.selectedSegmentIndex = 1
//        }
    
    // MARK: - Initialization
    
    // MARK: - Functions
    override func render() {
        view.backgroundColor = .bgWhite
        view.addSubViews([segmentedControl, pageViewController.view])
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-100)
            make.height.equalTo(48)
        }
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom)
        }
    }
    
    override func configUI() {
        self.segmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.textBrand,
                .font: UIFont.pretendard(.medium, ofSize: 16)
            ], for: .selected
        )
        self.segmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.textTertiary,
                .font: UIFont.pretendard(.medium, ofSize: 16)
            ],
            for: .normal
        )
        
        segmentedControl.rx.selectedSegmentIndex.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.segmentedControl.updateUnderlineViewWidth()
                self.segmentedControl.moveUnderlineView()
            })
            .disposed(by: disposeBag)
        
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
