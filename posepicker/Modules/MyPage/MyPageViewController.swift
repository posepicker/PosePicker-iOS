//
//  MyPageViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class MyPageViewController: BaseViewController {
    // MARK: - Functions
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .green
    }
}
