//
//  BaseCollectionViewCell.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import UIKit
import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render() {
        // Override Layout
    }
    
    func configUI() {
        // View Configuration
    }
}

