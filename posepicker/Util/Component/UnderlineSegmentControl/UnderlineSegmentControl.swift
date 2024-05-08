//
//  UnderlineSegmentControl.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class UnderlineSegmentControl: UISegmentedControl {
    // MARK: - Subviews
    
    private lazy var underlineView = UIView()
        .then {
            $0.backgroundColor = .mainViolet
        }
    
    // MARK: - Properties
    
    private lazy var previousXPosition = 0.0
    
    private var firstSegmentWidth: CGFloat {
        guard let firstSegmentTitle = titleForSegment(at: 0) else { return 0.0}
        return firstSegmentTitle.width(withConstrainedHeight: 24, font: .pretendard(.medium, ofSize: 16))
    }
    
    private var secondSegmentWidth: CGFloat {
        guard let secondSegmentTitle = titleForSegment(at: 1) else { return 0.0}
        return secondSegmentTitle.width(withConstrainedHeight: 24, font: .pretendard(.medium, ofSize: 16))
    }
    
    private var thirdSegmentWidth: CGFloat {
        guard let thirdSegmentTitle = titleForSegment(at: 2) else { return 0.0}
        return thirdSegmentTitle.width(withConstrainedHeight: 24, font: .pretendard(.medium, ofSize: 16))
    }
    
    private var fourthSegmentWidth: CGFloat {
        guard let thirdSegmentTitle = titleForSegment(at: 3) else { return 0.0}
        return thirdSegmentTitle.width(withConstrainedHeight: 24, font: .pretendard(.medium, ofSize: 16))
    }
    
    private var perSegmentwidth: CGFloat {
        return ((self.bounds.width - (self.firstSegmentWidth + self.secondSegmentWidth + self.thirdSegmentWidth + self.fourthSegmentWidth)) / 8) // 텍스트가 가운데 정렬 & 세그먼트당 두조각 가짐
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeBackgroundAndDivider()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeBackgroundAndDivider()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        moveUnderlineView()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configUI()
        render()
    }
    
    // MARK: - Functions
    
    /// UISegmentedControl의 원래 배경과 divider를 제거
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func configUI() {
        self.addSubView(underlineView)
    }
    
    func render() {
        underlineView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo((self.bounds.width / CGFloat(self.numberOfSegments)))
            make.height.equalTo(2)
        }
    }
    
    /// underlineView가 이동해야 할 위치를 계산하고 animate를 통해 이동
    /// UISegment가 클릭될 때마다 호출됨
    func moveUnderlineView() {
        var underlineFinalXPosition = CGFloat(self.selectedSegmentIndex * 2 + 1) * self.perSegmentwidth
        
        switch self.selectedSegmentIndex {
        case 1:
            underlineFinalXPosition += self.firstSegmentWidth
        case 2:
            underlineFinalXPosition += self.secondSegmentWidth + self.firstSegmentWidth
        case 3:
            underlineFinalXPosition += self.firstSegmentWidth + self.secondSegmentWidth + self.thirdSegmentWidth
        default:
            break
        }
        
        self.underlineView.frame.origin.x = previousXPosition
        
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.previousXPosition = underlineFinalXPosition
                self.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
    }
    
    func updateUnderlineViewWidth() {
        var width = 0.0
        switch self.selectedSegmentIndex {
        case 0:
            width = self.firstSegmentWidth
        case 1:
            width = self.secondSegmentWidth
        case 2:
            width = self.thirdSegmentWidth
        case 3:
            width = self.fourthSegmentWidth
        default:
            break
        }
        self.underlineView.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
        
        self.layoutIfNeeded()

    }

}
