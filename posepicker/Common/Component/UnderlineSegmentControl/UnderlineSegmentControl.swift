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
    
    private var previousXPosition = 0.0
    
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
        let fontAttributes = titleTextAttributes(for: .normal)
        guard let title = titleForSegment(at: self.selectedSegmentIndex) else { return }
        let size = title.size(withAttributes: fontAttributes)
        
        let perSegmentWidth = self.bounds.width / CGFloat(self.numberOfSegments) // 세그먼트 별 길이
        let underlineFinalXPosition = (perSegmentWidth * CGFloat(self.selectedSegmentIndex)) + (perSegmentWidth - size.width) / 2
        
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
        let fontAttributes = titleTextAttributes(for: .normal)
        guard let title = titleForSegment(at: self.selectedSegmentIndex) else { return }
        let size = title.size(withAttributes: fontAttributes)

        self.underlineView.snp.updateConstraints { make in
            make.width.equalTo(size.width)
        }
        
        self.layoutIfNeeded()

    }

}
