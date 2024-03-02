//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit

class MyPoseViewController: BaseViewController, UIGestureRecognizerDelegate {
    
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
        MyPoseImageSourceViewController(),
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
        
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
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
        
        /// 마이포즈 태그 입력 완료여부에 따라 마이포즈 이미지 출처 뷰로 이동시킬지 말지 판단
        /// 세그먼트 & 페이징 관련 로직
        if let myposeTagViewController = viewControllers[2] as? MyPoseTagViewController {
            myposeTagViewController.inputCompleted.asDriver()
                .drive(onNext: { [weak self] in
                    self?.pageViewController.dataSource = nil
                    self?.pageViewController.dataSource = self
                    if $0 {
                        self?.buttons[3].isEnabled = true
                        // self?.buttons[3].backgroundColor = .gray100
                        // self?.buttons[3].setTitleColor(.violet600, for: .normal)
                    } else {
                        self?.buttons[3].isEnabled = false
                        // self?.buttons[3].setTitleColor(.textWhite, for: .disabled)
                    }
                })
                .disposed(by: disposeBag)
        }
        
        viewControllers.enumerated().forEach { [weak self] index, vc in
            guard let self = self else { return }
            switch index {
            case 0:
                guard let myposeHeadVC = vc as? MyPoseHeadcountViewController else { return }
                myposeHeadVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 1
                    })
                    .disposed(by: self.disposeBag)
            case 1:
                guard let myposeFrameVC = vc as? MyPoseFramecountViewController else { return }
                myposeFrameVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 2
                    })
                    .disposed(by: self.disposeBag)
            case 2:
                guard let myposeTagVC = vc as? MyPoseTagViewController else { return }
                myposeTagVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 3
                    })
                    .disposed(by: self.disposeBag)
            case 3:
                guard let myposeImageSourceVC = vc as? MyPoseImageSourceViewController else { return }
                myposeImageSourceVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: {
                        // 데이터 업로드 API 통신
                        print("API 통신중..")
                    })
                    .disposed(by: disposeBag)
            default:
                return
            }
        }
    }
    
    func resetButtonUI() {
        buttons.forEach { $0.isCurrent = false }
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        
        // 마이포즈 태그 입력이 안끝났으면 이미지 출처 페이지로 슬라이드 이동하는 동작 막기
        if let myposeTagVC = viewControllers[2] as? MyPoseTagViewController,
           !myposeTagVC.inputCompleted.value && index == 3 {
            return
        }
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
        
        if let myposeTagVC = viewControllers[2] as? MyPoseTagViewController,
           !myposeTagVC.inputCompleted.value && index == 2 {
            return nil
        }
        
        return self.viewControllers[index + 1]
    }
}
