//
//  MyPoseViewController.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift

final class MyPoseViewController: BaseViewController {
    
    // MARK: - Subviews
    
//    lazy var segmentControl = UnderlineSegmentControl(items: ["포즈픽", "포즈톡", "포즈피드", "마이포즈"])
//        .then {
//            $0.apportionsSegmentWidthsByContent = true
//            $0.selectedSegmentTintColor = .mainViolet
//            $0.selectedSegmentIndex = 0
//        }
    let segmentControl = UISegmentedControl(items: ["등록 0", "저장 0"])
        .then {
            $0.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.textTertiary
            ], for: .normal)
            
            $0.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.mainViolet
            ], for: .selected)
            
            $0.selectedSegmentIndex = 0
        }
    
    // MARK: - Properties
    var viewModel: MyPoseViewModel?
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    
    
    override func configUI() {
        
    }
    
    override func render() {
        view.addSubViews([segmentControl])
        
        segmentControl.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
        }
    }
    
    override func bindViewModel() {
        let input = MyPoseViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        configureOutput(output)
    }
}

private extension MyPoseViewController {
    func configureOutput(_ output: MyPoseViewModel.Output?) {
        output?.uploadedCount
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.setTitle($0, forSegmentAt: 0)
            })
            .disposed(by: disposeBag)
        
        output?.savedCount
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.segmentControl.setTitle($0, forSegmentAt: 1)
            })
            .disposed(by: disposeBag)
    }
}
