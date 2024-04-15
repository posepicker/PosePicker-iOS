//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/22/24.
//

import UIKit

import Alamofire
import RxSwift
import RxCocoa

class PoseUploadViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews
    
    let buttons = [CircleSegmentButton(title: "1", isCurrent: true), CircleSegmentButton(title: "2"), CircleSegmentButton(title: "3"), CircleSegmentButton(title: "4")]
    
    lazy var pageButtons = UIStackView(arrangedSubviews: self.buttons)
        .then {
            $0.distribution = .fillEqually
            $0.alignment = .center
            $0.axis = .horizontal
            $0.spacing = 12
        }
    
    var pageViewController: UIPageViewController
    
    // MARK: - Properties
    let registeredImage: UIImage?
    private let currentPage = BehaviorRelay<Int>(value: 0)
    private let pageviewControllerDidFinishEvent = PublishSubject<Void>()

    var isLoading = BehaviorRelay<Bool>(value: false)
    
    var viewModel: PoseUploadViewModel?
    
    private let checkTagInputCompleted = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Initialization
    init(pageViewController: UIPageViewController, registeredImage: UIImage?) {
        self.pageViewController = pageViewController
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(UIScreen.main.isWiderThan375pt ? 48 : 16)
        }
        
        pageViewController.view.layer.zPosition = 10
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(pageButtons.snp.bottom).offset(UIScreen.main.isWiderThan375pt ? 36 : 16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .bgWhite
        
        let backButton = UIBarButtonItem(image: ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        buttons.enumerated().forEach { [weak self] (index, button) in
            guard let self = self else { return }
            
            button.rx.tap
                .subscribe(onNext: {
                    if index == 3 &&                     !self.checkTagInputCompleted.value {
                        return
                    }
                    UIView.animate(withDuration: 0.1) {
                        button.isCurrent = true
                        self.currentPage.accept(index)
                        self.setButtonUI()
                    }
                })
                .disposed(by: self.disposeBag)
        }
        buttons[0].isCurrent = true
        
        currentPage
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.setButtonUI()
            })
            .disposed(by: disposeBag)
    }
    
    // 입력 최종 완료 후 API통신을 위한 객체
    override func bindViewModel() {
        let input = PoseUploadViewModel.Input(
            pageviewTransitionDelegateEvent: pageviewControllerDidFinishEvent,
            currentPage: currentPage.asObservable()
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
    }
    
    func setButtonUI() {
        buttons.enumerated().forEach { (index, button) in
            if index <= currentPage.value {
                UIView.animate(withDuration: 0.1) {
                    button.isCurrent = true
                }
            }
            
            if index > currentPage.value {
                UIView.animate(withDuration: 0.1) {
                    button.isCurrent = false
                }
            }
        }
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        self.dismiss(animated: true)
    }
}

extension PoseUploadViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        self.pageviewControllerDidFinishEvent.onNext(())
    }
}

extension PoseUploadViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.viewModel?.viewControllerBefore()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.viewModel?.viewControllerAfter()
    }
}

private extension PoseUploadViewController {
    func configureOutput(_ output: PoseUploadViewModel.Output?) {
        output?.pageTransitionEvent
            .bind(to: currentPage)
            .disposed(by: disposeBag)
        
        output?.selectedSegmentIndex
            .asDriver()
            .drive(onNext: { [weak self] pageIndex in
                self?.buttons[pageIndex].isCurrent = true
                self?.buttons.enumerated().forEach { (index, button) in
                    if index <= pageIndex {
                        UIView.animate(withDuration: 0.1) {
                            button.isCurrent = true
                        }
                    }
                    
                    if index > pageIndex {
                        UIView.animate(withDuration: 0.1) {
                            button.isCurrent = false
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.isMovableToImageSourceView
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.checkTagInputCompleted.accept($0)
            })
            .disposed(by: disposeBag)
    }
}
