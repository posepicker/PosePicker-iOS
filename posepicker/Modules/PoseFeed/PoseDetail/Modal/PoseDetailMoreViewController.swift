//
//  PoseDetailMoreViewController.swift
//  posepicker
//
//  Created by 박경준 on 3/7/24.
//

import UIKit

class PoseDetailMoreViewController: BaseViewController {

    // MARK: - Subviews
    
    // MARK: - Properties
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentationController?.containerView?.backgroundColor = .dimmed70
    }
    
    // MARK: - Functions
    override func render() {
        
    }
    
    override func configUI() {
        self.view.backgroundColor = .bgWhite
    }
}
