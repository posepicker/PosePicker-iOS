//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit

class MyPoseViewController: BaseViewController {
    
    // MARK: - Subviews
    
    let buttons = [CircleSegmentButton(title: "1", isCurrent: true), CircleSegmentButton(title: "2"), CircleSegmentButton(title: "3"), CircleSegmentButton(title: "4")]
    
    lazy var pageButtons = UIStackView(arrangedSubviews: self.buttons)
        .then {
            $0.distribution = .fillEqually
            $0.alignment = .center
            $0.axis = .horizontal
            $0.spacing = 12
        }
    
    lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        .then {
            $0.setViewControllers([self.viewControllers[0]], direction: .forward, animated: true)
            $0.dataSource = self
            $0.delegate = self
        }
    
    // MARK: - Properties
    let registeredImage: UIImage?
    
    lazy var viewControllers: [UIViewController] = [
        MyPoseHeadcountViewController(registeredImage: self.registeredImage),
        MyPoseFramecountViewController(registeredImage: self.registeredImage),
        MyPoseTagViewController(registeredImage: self.registeredImage),
        MyPoseImageSourceViewController(registeredImage: self.registeredImage),
    ]
    
    var currentPage: Int = 0 {
        didSet {
            // from segmentedControl -> pageViewController 업데이트
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [self.viewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
            resetButtonUI()
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let self = self else { return }
                self.buttons[currentPage].isCurrent = true
            }
        }
    }

    
    // MARK: - Initialization
    init(registeredImage: UIImage?) {
        self.registeredImage = registeredImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        view.addSubViews([pageButtons, pageViewController.view])
        
        pageButtons.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(132)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(48)
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(pageButtons.snp.bottom).offset(36)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .bgWhite
        
        buttons.enumerated().forEach { [weak self] (index, button) in
            guard let self = self else { return }
            
            button.rx.tap
                .subscribe(onNext: {
                    UIView.animate(withDuration: 0.1) {
                        self.resetButtonUI()
                        button.isCurrent = true
                        self.currentPage = index
                    }
                })
                .disposed(by: self.disposeBag)
        }
        buttons[0].isCurrent = true
    }
    
    func resetButtonUI() {
        buttons.forEach { $0.isCurrent = false }
    }
}

extension MyPoseViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = viewControllers.firstIndex(of: viewController) else { return }
        currentPage = index
    }
}

extension MyPoseViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController),
              index - 1 >= 0 else { return nil}
        return self.viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController),
              index + 1 < viewControllers.count else { return nil }
        return self.viewControllers[index + 1]
    }
}
