//
//  MyPageViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class MyPageViewController: BaseViewController {
    
    // MARK: - Properties
    var viewModel: MyPageViewModel
    var coordinator: RootCoordinator
    
    // MARK: - Life Cycles
    
    init(viewModel: MyPageViewModel, coordinator: RootCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .green
    }
}
