//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift
import RxRelay

final class MyPoseViewController: BaseViewController {
    
    // MARK: - Subviews
    
    let segmentControl = UISegmentedControl(items: ["등록 0", "저장 0"])
        .then {
            $0.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.textTertiary
            ], for: .normal)
            
            $0.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.mainViolet
            ], for: .selected)
            
            $0.selectedSegmentIndex = 0
        }
    
    let pageViewController: UIPageViewController
    
    // MARK: - Properties
    var viewModel: MyPoseViewModel?
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    private let pageviewControllerDidFinishEvent = PublishSubject<Void>()
    private let currentPageViewIndex = BehaviorRelay<Int>(value: 0)
    let refreshCountTrigger = PublishSubject<Void>()
    
    // MARK: - Initialization
    init(pageViewController: UIPageViewController) {
        self.pageViewController = pageViewController
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    
    
    override func configUI() {
        segmentControl.rx.selectedSegmentIndex.asDriver()
            .drive(onNext: { [weak self] in
                self?.currentPageViewIndex.accept($0)
            })
            .disposed(by: disposeBag)
        
        currentPageViewIndex
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.selectedSegmentIndex = $0
            })
            .disposed(by: self.disposeBag)
    }
    
    override func render() {
        view.addSubViews([segmentControl, pageViewController.view])
        
        segmentControl.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(segmentControl.snp.bottom).offset(12)
        }
    }
    
    override func bindViewModel() {
        let input = MyPoseViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            pageviewTransitionDelegateEvent: pageviewControllerDidFinishEvent,
            currentPageViewIndex: currentPageViewIndex.asObservable(),
            refreshCountEvent: refreshCountTrigger
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
    }
}

private extension MyPoseViewController {
    func configureOutput(_ output: MyPoseViewModel.Output?) {
        output?.uploadedCount
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.setTitle($0, forSegmentAt: 0)
            })
            .disposed(by: disposeBag)
        
        output?.savedCount
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.setTitle($0, forSegmentAt: 1)
            })
            .disposed(by: disposeBag)
        
        output?.pageTransitionEvent
            .bind(to: currentPageViewIndex)
            .disposed(by: disposeBag)
    }
}

extension MyPoseViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.pageviewControllerDidFinishEvent.onNext(())
    }
}

extension MyPoseViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewModel?.viewControllerBefore()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewModel?.viewControllerAfter()
    }
}
