//
//  UICollectionView+.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit

extension UICollectionView {
    func updateCollectionViewHeight(){
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        if(self.contentSize.height > self.frame.height){
            self.snp.updateConstraints {
                $0.height.equalTo(self.contentSize.height)
            }
        }
    }
}
