//
//  CommonViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit
import RxSwift
import RxRelay

class CommonViewController: BaseViewController {
    
    // MARK: - Subviews
    let header = Header()
    
    let divider = UIView()
        .then {
            $0.backgroundColor = .bgDivider
        }
    
    lazy var segmentControl = UnderlineSegmentControl(items: ["포즈픽", "포즈톡", "포즈피드", "마이포즈"])
        .then {
            $0.apportionsSegmentWidthsByContent = true
            $0.selectedSegmentTintColor = .mainViolet
            $0.selectedSegmentIndex = 0
        }
    
    // 코디네이터의 페이지 뷰 컨트롤러를 가져와야됨
    let pageViewController: UIPageViewController
    
    // MARK: - Properties
    var viewModel: CommonViewModel?
    let removeMyPoseContentsTrigger = PublishSubject<Void>()
    
    private let currentPage = BehaviorRelay<Int>(value: 0)
    private let pageviewControllerDidFinishEvent = PublishRelay<Void>()
    private let appleIdentityTokenTrigger = PublishSubject<String>()
    private let kakaoEmailTrigger = PublishSubject<String>()
    private let kakaoIdTrigger = PublishSubject<Int64>()
    
    // MARK: - Initialization
    init(pageViewController: UIPageViewController) {
        self.pageViewController = pageViewController
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
            .drive(onNext: { [weak self] in
                self?.currentPage.accept($0)
                self?.segmentControl.updateUnderlineViewWidth()
            })
            .disposed(by: disposeBag)
        
        currentPage
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.selectedSegmentIndex = $0
                self?.segmentControl.updateUnderlineViewWidth()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModel() {
        let input = CommonViewModel.Input(
            pageviewTransitionDelegateEvent: pageviewControllerDidFinishEvent.asObservable(),
            myPageButtonTapEvent: header.menuButton.rx.tap.asObservable(),
            currentPage: currentPage.asObservable(),
            bookmarkButtonTapEvent: header.bookMarkButton.rx.tap.asObservable(),
            removeMyPoseContentsEvent: removeMyPoseContentsTrigger
        )
        let output = self.viewModel?.transform(from: input, disposeBag: disposeBag)
        configureOutput(output)
    }
}

extension CommonViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        self.pageviewControllerDidFinishEvent.accept(())
    }
}

extension CommonViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewModel?.viewControllerBefore()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewModel?.viewControllerAfter()
    }
}

private extension CommonViewController {
    func configureOutput(_ output: CommonViewModel.Output?) {
        output?.pageTransitionEvent
            .bind(to: currentPage)
            .disposed(by: disposeBag)
    }
}
