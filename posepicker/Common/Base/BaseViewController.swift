//
//  BaseViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit
import RxSwift
import SnapKit
import Then

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()
        bindViewModel()
    }
    
    func render() {
        // Override Layout
    }
    
    func configUI() {
        // View Configuration
    }
    
    func bindViewModel() {
        // view model binding
    }
}
