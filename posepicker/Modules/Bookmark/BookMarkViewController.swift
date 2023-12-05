//
//  BookMarkViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

class BookMarkViewController: BaseViewController {
    
    // MARK: - Subviews
    
    let emptyView = EmptyBookmarkView()
    
    // MARK: - Properties
    var viewModel: BookMarkViewModel
    var coordinator: RootCoordinator
    
    let viewDidLoadTrigger = PublishSubject<Void>()
    
    // MARK: - Initialization
    
    init(viewModel: BookMarkViewModel, coordinator: RootCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([emptyView])
        
        emptyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(52)
            make.height.equalTo(170)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(80)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "북마크"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = .bgWhite
        
        /// 뒤로가기 버튼 탭
        emptyView.toPoseFeedButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.coordinator.moveWithPage(page: .posefeed, direction: .reverse)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = BookMarkViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger)
        let output = viewModel.transform(input: input)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
