//
//  MyPoseTagViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit
import RxSwift
import RxCocoa

class MyPoseTagViewController: BaseViewController {
    // MARK: - Subviews
    let mainLabel = UILabel()
        .then {
            let attributedText = NSMutableAttributedString(string: "최소 3개 이상", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "\n태그를 선택해주세요!", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    let tagCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .bgWhite
        cv.register(PoseFeedFilterCell.self, forCellWithReuseIdentifier: PoseFeedFilterCell.identifier)
        return cv
    }()
    
    let tagTextField = UITextField()
        .then {
            $0.textColor = .iconDefault
            $0.font = .subTitle2
            $0.placeholder = "원하는 태그를 입력하고 enter를 눌러주세요."
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.backgroundColor = .clear
        }
    
    lazy var tagFromTextFieldCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PoseFeedFilterCell.self, forCellWithReuseIdentifier: self.tagFromTextFieldCollectionViewIdentifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    
    let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    let tagItemsFromTextField = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    let tagFromTextFieldCollectionViewIdentifier = PoseFeedFilterCell.identifier + "FromTextField"
    // MARK: - Initialization
    init(registeredImage: UIImage?) {
        self.registeredImage = registeredImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([mainLabel, tagCollectionView, tagTextField, tagFromTextFieldCollectionView, registeredImageView, nextButton])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(36)
            make.leading.equalTo(mainLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(84)
        }
        
        tagTextField.snp.makeConstraints { make in
            make.top.equalTo(tagCollectionView.snp.bottom).offset(24)
            make.leading.equalTo(tagFromTextFieldCollectionView.snp.trailing)
//            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }
        
        tagFromTextFieldCollectionView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(tagTextField)
            make.width.equalTo(tagFromTextFieldCollectionView.collectionViewLayout.collectionViewContentSize.width)
        }
        
        registeredImageView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(160)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-27)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        
    }
    
    override func bindViewModel() {
        // 1. 기본 태그 세팅
        tagItems.accept(FilterTags.getAllFilterTags().map {
            PoseFeedFilterCellViewModel(title: $0.rawValue)
        })
        
        tagItems.asDriver()
            .drive(tagCollectionView.rx.items(cellIdentifier: PoseFeedFilterCell.identifier, cellType: PoseFeedFilterCell.self)) { _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
        .disposed(by: disposeBag)
        
        // 2. 텍스트필드 입력 후 태그세팅
        
        tagTextField.rx.controlEvent(.editingDidEndOnExit)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if let text = owner.tagTextField.text,
                   !text.isEmpty {
                    let vm = PoseFeedFilterCellViewModel(title: text)
                    vm.isSelected.accept(true)
                    owner.tagItemsFromTextField.accept(owner.tagItemsFromTextField.value + [vm])

                    owner.tagFromTextFieldCollectionView.snp.updateConstraints { make in
                        make.width.equalTo(owner.tagFromTextFieldCollectionView.frame.width + text.width(withConstrainedHeight: 32, font: .pretendard(.medium, ofSize: 14)) + 32)
                    }
                    
                    owner.tagTextField.snp.updateConstraints { make in
                        make.leading.equalTo(owner.tagFromTextFieldCollectionView.snp.trailing)
                    }
                    owner.tagTextField.rx.text.onNext("")
                }
            })
            .disposed(by: disposeBag)
        
        tagItemsFromTextField.asDriver()
            .drive(tagFromTextFieldCollectionView.rx.items(cellIdentifier: tagFromTextFieldCollectionViewIdentifier, cellType: PoseFeedFilterCell.self)) { _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
        .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tagTextField.endEditing(true)
    }
}
