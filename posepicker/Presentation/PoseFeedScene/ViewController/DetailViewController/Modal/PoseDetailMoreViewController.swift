//
//  PoseDetailMoreViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/7/24.
//

import UIKit
import RxCocoa
import RxSwift

class PoseDetailMoreViewController: BaseViewController {

    // MARK: - Subviews
    let closeButton = UIBarButtonItem(image: ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault), style: .plain, target: self, action: #selector(closeButtonTapped))
    
    lazy var navigationBar = UINavigationBar()
        .then {
            let navigationItem = UINavigationItem(title: "")
            navigationItem.rightBarButtonItem = self.closeButton
            $0.items = [navigationItem]
            $0.barTintColor = .bgWhite
        }
    
    let reportButton = UIButton(type: .system)
        .then {
            $0.setTitle("신고하기", for: .normal)
            $0.setTitleColor(.textPrimary, for: .normal)
            $0.contentHorizontalAlignment = .leading
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
        }
    
//    let blockButton = UIButton(type: .system)
//        .then {
//            $0.setTitle("차단하기", for: .normal)
//            $0.setTitleColor(.textPrimary, for: .normal)
//            $0.contentHorizontalAlignment = .leading
//            $0.titleLabel?.font = .pretendard(.medium, ofSize: 16)
//        }
    
    // MARK: - Properties
    let poseId: Int
    var viewModel: PoseDetailMoreViewModel?
    
    // MARK: - Initialization
    
    init(poseId: Int) {
        self.poseId = poseId
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentationController?.containerView?.backgroundColor = .dimmed70
    }
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([navigationBar, reportButton/*, blockButton*/])
        
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.top)
            make.height.equalTo(50)
        }
        
        reportButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalTo(view).inset(20)
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
//        blockButton.snp.makeConstraints { make in
//            make.height.equalTo(48)
//            make.leading.trailing.equalTo(view).inset(20)
//            make.top.equalTo(reportButton.snp.bottom)
//        }
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
        
        // 네비게이션 바 보더라인 삭제
        self.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layoutIfNeeded()
        
        // 1. 신고하기 버튼 탭
//        reportButton.rx.tap
//            .asDriver()
//            .drive(onNext: { [weak self] in
//                guard let self = self else { return }
//                let reportVC = ReportViewController(poseId: self.poseId)
//                let navigationVC = UINavigationController(rootViewController: reportVC)
//                navigationVC.modalPresentationStyle = .overFullScreen
//                navigationVC.modalTransitionStyle = .coverVertical
//                self.present(navigationVC, animated: true)
//            })
//            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = PoseDetailMoreViewModel.Input(
            closeButtonTapEvent: closeButton.rx.tap.asObservable(),
            reportButtonTapEvent: reportButton.rx.tap.flatMapLatest { Observable.just(self.poseId) }
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}

private extension PoseDetailMoreViewController {
    func configureOutput(_ output: PoseDetailMoreViewModel.Output?) {
        
    }
}
