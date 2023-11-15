//
//  PoseDetailViewController.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit

class PoseDetailViewController: BaseViewController {

    // MARK: - Subviews
    
    // MARK: - Properties
    
    var viewModel: PoseDetailViewModel
    var coordinator: PoseFeedCoordinator
    
    // MARK: - Initialization
    
    init(viewModel: PoseDetailViewModel, coordinator: PoseFeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
