//
//  LeftAlignedCollectionViewFlowLayout.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit

/// 두 줄 이상의 컬렉션 뷰에서만 왼쪽 정렬중
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        let padding: CGFloat = UIScreen.main.isWiderThan375pt ? 5 : 15
        
        attributes?.forEach { layoutAttribute in
            // MARK: 한줄 넘어간 시점에 y값을 초기화해주는 코드
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            // MARK: 컬렉션뷰 배치가 완료된 이후에 minimum space를 더해주고 있음 -> 오토레이아웃에 상관 없이 벗어나게 되는것
            
            leftMargin += layoutAttribute.frame.width + padding
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
