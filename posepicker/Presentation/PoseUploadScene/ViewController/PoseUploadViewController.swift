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
        PoseUploadHeadcountViewController(registeredImage: self.registeredImage),
        PoseUploadFramecountViewController(registeredImage: self.registeredImage),
        PoseUploadTagViewController(registeredImage: self.registeredImage),
        PoseUploadImageSourceViewController(),
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
            setButtonUI()
        }
    }

    var isLoading = BehaviorRelay<Bool>(value: false)
    
    var apiSession: APIService = APISession()
    
    
    
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
                        self.setButtonUI()
                        button.isCurrent = true
                        self.currentPage = index
                    }
                })
                .disposed(by: self.disposeBag)
        }
        buttons[0].isCurrent = true
        
        /// 마이포즈 태그 입력 완료여부에 따라 마이포즈 이미지 출처 뷰로 이동시킬지 말지 판단
        /// 세그먼트 & 페이징 관련 로직
        if let myposeTagViewController = viewControllers[2] as? PoseUploadTagViewController {
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
                guard let myposeHeadVC = vc as? PoseUploadHeadcountViewController else { return }
                myposeHeadVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 1
                    })
                    .disposed(by: self.disposeBag)
            case 1:
                guard let myposeFrameVC = vc as? PoseUploadFramecountViewController else { return }
                myposeFrameVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 2
                    })
                    .disposed(by: self.disposeBag)
            case 2:
                guard let myposeTagVC = vc as? PoseUploadTagViewController else { return }
                myposeTagVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.currentPage = 3
                    })
                    .disposed(by: self.disposeBag)
            case 3:
                guard let myposeImageSourceVC = vc as? PoseUploadImageSourceViewController else { return }
                myposeImageSourceVC.nextButton.rx.tap
                    .asDriver()
                    .drive(onNext: {
                        // 데이터 업로드 API 통신
                        print("API 통신중..")
                    })
                    .disposed(by: disposeBag)
                
                isLoading
                    .map { !$0 }
                    .bind(to: myposeImageSourceVC.loadingIndicator.rx.isHidden)
                    .disposed(by: disposeBag)
                
                isLoading.asDriver()
                    .drive(onNext: { loading in
                        if loading {
                            myposeImageSourceVC.loadingIndicator.isHidden = false
                            myposeImageSourceVC.nextButton.setTitle("", for: .normal)
                        } else {
                            myposeImageSourceVC.loadingIndicator.isHidden = true
                            myposeImageSourceVC.nextButton.setTitle("업로드", for: .normal)
                        }
                    })
                    .disposed(by: disposeBag)
            default:
                return
            }
        }
        
        // 로딩 인디케이터
        
        
    }
    
    // 입력 최종 완료 후 API통신을 위한 객체
    override func bindViewModel() {
        guard let headcountVC = viewControllers[0] as? PoseUploadHeadcountViewController,
              let framecountVC = viewControllers[1] as? PoseUploadFramecountViewController,
              let tagVC = viewControllers[2] as? PoseUploadTagViewController,
              let imageSourceVC = viewControllers[3] as? PoseUploadImageSourceViewController else {
            return
        }
        
        let selectedTagObservable = Observable.combineLatest(tagVC.tagItems, tagVC.tagItemsFromTextField)
            .flatMapLatest { items, itemsFromTextField -> Observable<[String]> in
                let allSelectedItems = BehaviorRelay<[String]>(value: [])
                
                items.forEach { item in
                    // 아이템 selcted면 종합 태그에 추가
                    // 아니면 삭제
                    if item.isSelected.value {
                        allSelectedItems.accept(allSelectedItems.value + [item.title.value])
                    } else {
                        if let index = allSelectedItems.value.firstIndex(where: { tag in
                            tag == item.title.value
                        }) {
                            var value = allSelectedItems.value
                            value.remove(at: index)
                            allSelectedItems.accept(value)
                        }
                    }
                }
                
                itemsFromTextField.forEach { item in
                    allSelectedItems.accept(allSelectedItems.value + [item.title.value])
                }
                return allSelectedItems.asObservable()
            }
        
        // 포즈 업로드
        imageSourceVC.nextButton.rx.tap
            .flatMapLatest { _ -> Observable<(String, String, [String], String)> in
                return Observable.combineLatest(headcountVC.selectedHeadCount, framecountVC.selectedFrameCount, selectedTagObservable, imageSourceVC.urlTextField.rx.text.compactMap { $0 })
            }
            .flatMapLatest { [weak self] headCount, frameCount, selectedTags, imageSource -> Single<Pose> in
                guard let self = self else { return Observable<Pose>.empty().asSingle() }
                var tagArrayToString = ""
                selectedTags.forEach { tagArrayToString += "\($0)," }
                self.isLoading.accept(true)
                return self.apiSession.requestMultipartSingle(.uploadPose(image: self.registeredImage, frameCount: frameCount, peopleCount: headCount, source: imageSource, sourceUrl: imageSource, tag: tagArrayToString))
            }
            .subscribe(onNext: { [weak self] posepick in
                self?.isLoading.accept(false)
//                let poseDetailViewModel = PoseDetailViewModel(poseDetailData: posepick)
//                let coordinator = PoseFeedCoordinator(navigationController: self!.navigationController!)
//                let detailVC = PoseDetailViewController(viewModel: poseDetailViewModel, coordinator: coordinator)
//                self?.present(detailVC, animated: true)
            }, onError: { [weak self] in
                self?.isLoading.accept(false)
                print("ERROR...")
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func setButtonUI() {
        buttons.enumerated().forEach { (index, button) in
            if index <= currentPage {
                UIView.animate(withDuration: 0.1) {
                    button.isCurrent = true
                }
            }
            
            if index > currentPage {
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
        if let myposeTagVC = viewControllers[2] as? PoseUploadTagViewController,
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
        
        if let myposeTagVC = viewControllers[2] as? PoseUploadTagViewController,
           !myposeTagVC.inputCompleted.value && index == 2 {
            return nil
        }
        
        return self.viewControllers[index + 1]
    }
}
