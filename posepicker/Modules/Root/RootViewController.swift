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
    let header = Header()
    
    let divider = UIView()
        .then {
            $0.backgroundColor = .bgDivider
        }
    
    lazy var segmentControl = UnderlineSegmentControl(items: ["포즈픽", "포즈톡", "포즈피드"])
        .then {
            $0.selectedSegmentTintColor = .mainViolet
            $0.selectedSegmentIndex = 0
        }
    
    lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        .then {
            let pages: [RootPage] = [.posepick, .posetalk, .posefeed, .bookmark].sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
            viewControllers = pages.map { getNavigationController($0) }
            $0.dataSource = self
            $0.delegate = self
        }
    
    // MARK: - Properties
    var viewControllers: [UIViewController] = []
    var coordinator: RootCoordinator
    
    var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            coordinator.moveWithViewController(viewController: [viewControllers[self.currentPage]], direction: direction, pageNumber: currentPage)
        }
    }
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Initialization
    
    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        view.backgroundColor = .bgWhite
        view.addSubViews([header, segmentControl, divider, pageViewController.view])
        
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(48)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.equalTo(view).offset(10)
            make.trailing.equalTo(view).offset(-160)
            make.height.equalTo(48)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(divider.snp.bottom)
        }
    }
    
    override func configUI() {
        view.backgroundColor = .bgWhite
        divider.layer.zPosition = 999
        self.segmentControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.textBrand,
                .font: UIFont.pretendard(.medium, ofSize: 16)
            ], for: .selected
        )
        self.segmentControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.textTertiary,
                .font: UIFont.pretendard(.medium, ofSize: 16)
            ],
            for: .normal
        )
            
        segmentControl.rx.selectedSegmentIndex.asDriver()
            .drive(onNext: { [unowned self] in
                self.currentPage = $0
            })
            .disposed(by: disposeBag)
        
        header.menuButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.coordinator.push(page: .myPage)
            })
            .disposed(by: disposeBag)
        
        header.bookMarkButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.coordinator.push(page: .bookmark)
            })
            .disposed(by: disposeBag)
    }
    
    func getNavigationController(_ page: RootPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)
        
        switch page {
        case .posepick:
            let posePickerVC = PosePickViewController(viewModel: PosePickViewModel())
            navController.pushViewController(posePickerVC, animated: true)
        case .posetalk:
            let poseTalkVC = PoseTalkViewController(viewModel: PoseTalkViewModel(), coordinator: self.coordinator)
            navController.pushViewController(poseTalkVC, animated: true)
        case .posefeed:
            let poseFeedVC = PoseFeedViewController(viewModel: PoseFeedViewModel(), coordinator: PoseFeedCoordinator(navigationController: navController))
            navController.pushViewController(poseFeedVC, animated: true)
        case .bookmark:
            let bookmarkVC = BookMarkViewController(viewModel: BookMarkViewModel(), coordinator: self.coordinator)
            navController.pushViewController(bookmarkVC, animated: true)
        case .myPage:
            let myPageVC = MyPageViewController(viewModel: MyPageViewModel(), coordinator: self.coordinator)
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
        coordinator.moveWithSegment(pageNumber: index)
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
