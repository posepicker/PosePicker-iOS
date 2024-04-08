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
    
    lazy var segmentControl = UnderlineSegmentControl(items: ["포즈픽", "포즈톡", "포즈피드"])
        .then {
            $0.apportionsSegmentWidthsByContent = true
            $0.selectedSegmentTintColor = .mainViolet
            $0.selectedSegmentIndex = 0
        }
    
    // 코디네이터의 페이지 뷰 컨트롤러를 가져와야됨
    let pageViewController: UIPageViewController
    
    // MARK: - Properties
    var viewModel: CommonViewModel?
    private let loginCompletedTrigger = PublishSubject<Void>()
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
        
//        header.menuButton.rx.tap.asDriver()
//            .drive(onNext: { [weak self] in
//                self.coordinator.push(page: .myPage)
//            })
//            .disposed(by: disposeBag)
        
        header.bookMarkButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                /// 로그인 되어 있으면 coordinator.push
                /// 로그인 되어 있지 않으면 로그인뷰 팝업
//                if AppCoordinator.loginState {
//                    self.coordinator.push(page: .bookmark)
//                } else {
//                    let popUpVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
//                    popUpVC.modalTransitionStyle = .crossDissolve
//                    popUpVC.modalPresentationStyle = .overFullScreen
//                    self.present(popUpVC, animated: true)
//                    
//                    // 토큰 세팅
//                    popUpVC.appleIdentityToken
//                        .compactMap { $0 }
//                        .subscribe(onNext: { [unowned self] in
//                            self.appleIdentityTokenTrigger.onNext($0)
//                        })
//                        .disposed(by: self.disposeBag)
//                    
//                    popUpVC.email
//                        .compactMap { $0 }
//                        .subscribe(onNext: { [unowned self] in
//                            self.kakaoEmailTrigger.onNext($0)
//                        })
//                        .disposed(by: disposeBag)
//                    
//                    popUpVC.kakaoId
//                        .compactMap { $0 }
//                        .subscribe(onNext: { [unowned self] in
//                            self.kakaoIdTrigger.onNext($0)
//                        })
//                        .disposed(by: disposeBag)
//                }
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = CommonViewModel.Input(
            pageviewTransitionDelegateEvent: pageviewControllerDidFinishEvent.asObservable(),
            myPageButtonTapEvent: header.menuButton.rx.tap.asObservable(),
            currentPage: currentPage.asObservable(),
            bookmarkButtonTapEvent: header.bookMarkButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(from: input, disposeBag: disposeBag)
        configureOutput(output)
        
//        let input = RootViewModel.Input(appleIdentityTokenTrigger: appleIdentityTokenTrigger, kakaoLoginTrigger: Observable.combineLatest(kakaoEmailTrigger, kakaoIdTrigger))
//        
//        let output = viewModel.transform(input: input)
//
//        output.dismissLoginView
//            .subscribe(onNext: { [unowned self] in
//                guard let popupVC = self.presentedViewController as? PopUpViewController,
//                      let _ = popupVC.popUpView as? LoginPopUpView else { return }
//                self.loginCompletedTrigger.onNext(())
//                self.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)
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
