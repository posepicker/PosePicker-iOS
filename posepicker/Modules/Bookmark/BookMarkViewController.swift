//
//  BookMarkViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class BookMarkViewController: BaseViewController {
    
    // MARK: - Subviews
    
    let emptyView = EmptyBookmarkView()
    
    // MARK: - Properties
    var viewModel: BookMarkViewModel
    
    // MARK: - Initialization
    
    init(viewModel: BookMarkViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([emptyView])
        
        emptyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(52)
            make.height.equalTo(170)
            make.top.equalToSuperview().offset(80)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
    }
}
