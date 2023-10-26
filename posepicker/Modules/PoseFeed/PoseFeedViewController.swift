//
//  PoseFeedViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class PoseFeedViewController: BaseViewController {
    
    // MARK: - Subviews
    let filterButton = UIButton(type: .system)
        .then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 14)
            $0.tintColor = .textSecondary
            $0.backgroundColor = .bgSubWhite
            $0.semanticContentAttribute = .forceRightToLeft
            $0.setImage(ImageLiteral.imgCaretDown, for: .normal)
            $0.setTitle("필터", for: .normal)
        }
    
    // MARK: - Properties
    
    var viewModel: PoseFeedViewModel
    var coordinator: PoseFeedCoordinator
    
    // MARK: - Initialization
    
    init(viewModel: PoseFeedViewModel, coordinator: PoseFeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([filterButton])
        
        filterButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
    }
    
    override func bindViewModel() {
        let input = PoseFeedViewModel.Input(filterButtonTapped: filterButton.rx.controlEvent(.touchUpInside))
        
        let output = viewModel.transform(input: input)
        
        output.presentModal
            .drive(onNext: { [unowned self] in
                self.coordinator.presentModal()
            })
            .disposed(by: disposeBag)
    }
}
