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
    
    var apiSession: APIService = APISession()
    
    var viewModel: PoseUploadViewModel?
    
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
        
//        segmentControl.rx.selectedSegmentIndex.asDriver()
//            .drive(onNext: { [weak self] in
//                self?.currentPage.accept($0)
//                self?.segmentControl.updateUnderlineViewWidth()
//            })
//            .disposed(by: disposeBag)
//        
//        currentPage
//            .asDriver()
//            .drive(onNext: { [weak self] in
//                self?.segmentControl.selectedSegmentIndex = $0
//                self?.segmentControl.updateUnderlineViewWidth()
//            })
//            .disposed(by: self.disposeBag)
        
//        /// 마이포즈 태그 입력 완료여부에 따라 마이포즈 이미지 출처 뷰로 이동시킬지 말지 판단
//        /// 세그먼트 & 페이징 관련 로직
//        if let myposeTagViewController = viewControllers[2] as? PoseUploadTagViewController {
//            myposeTagViewController.inputCompleted.asDriver()
//                .drive(onNext: { [weak self] in
//                    self?.pageViewController.dataSource = nil
//                    self?.pageViewController.dataSource = self
//                    if $0 {
//                        self?.buttons[3].isEnabled = true
//                        // self?.buttons[3].backgroundColor = .gray100
//                        // self?.buttons[3].setTitleColor(.violet600, for: .normal)
//                    } else {
//                        self?.buttons[3].isEnabled = false
//                        // self?.buttons[3].setTitleColor(.textWhite, for: .disabled)
//                    }
//                })
//                .disposed(by: disposeBag)
//        }
//        
//        viewControllers.enumerated().forEach { [weak self] index, vc in
//            guard let self = self else { return }
//            switch index {
//            case 0:
//                guard let myposeHeadVC = vc as? PoseUploadHeadcountViewController else { return }
//                myposeHeadVC.nextButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.currentPage = 1
//                    })
//                    .disposed(by: self.disposeBag)
//            case 1:
//                guard let myposeFrameVC = vc as? PoseUploadFramecountViewController else { return }
//                myposeFrameVC.nextButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.currentPage = 2
//                    })
//                    .disposed(by: self.disposeBag)
//            case 2:
//                guard let myposeTagVC = vc as? PoseUploadTagViewController else { return }
//                myposeTagVC.nextButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.currentPage = 3
//                    })
//                    .disposed(by: self.disposeBag)
//            case 3:
//                guard let myposeImageSourceVC = vc as? PoseUploadImageSourceViewController else { return }
//                myposeImageSourceVC.nextButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: {
//                        // 데이터 업로드 API 통신
//                        print("API 통신중..")
//                    })
//                    .disposed(by: disposeBag)
//                
//                isLoading
//                    .map { !$0 }
//                    .bind(to: myposeImageSourceVC.loadingIndicator.rx.isHidden)
//                    .disposed(by: disposeBag)
//                
//                isLoading.asDriver()
//                    .drive(onNext: { loading in
//                        if loading {
//                            myposeImageSourceVC.loadingIndicator.isHidden = false
//                            myposeImageSourceVC.nextButton.setTitle("", for: .normal)
//                        } else {
//                            myposeImageSourceVC.loadingIndicator.isHidden = true
//                            myposeImageSourceVC.nextButton.setTitle("업로드", for: .normal)
//                        }
//                    })
//                    .disposed(by: disposeBag)
//            default:
//                return
//            }
//        }
//        
//        // 로딩 인디케이터
//        
        
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
    }
}
