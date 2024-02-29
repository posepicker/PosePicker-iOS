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
    
    let textFieldScrollView = UIScrollView()
        .then { sv in
            sv.layer.borderColor = UIColor.borderDefault.cgColor
            sv.layer.borderWidth = 1
            sv.layer.cornerRadius = 8
            let view = UIView()
            sv.addSubview(view)
            sv.showsHorizontalScrollIndicator = false
            view.snp.makeConstraints {
                $0.top.equalTo(sv.contentLayoutGuide.snp.top)
                $0.leading.equalTo(sv.contentLayoutGuide.snp.leading)
                $0.trailing.equalTo(sv.contentLayoutGuide.snp.trailing)
                $0.bottom.equalTo(sv.contentLayoutGuide.snp.bottom)

                $0.top.equalTo(sv.frameLayoutGuide.snp.top)
                $0.bottom.equalTo(sv.frameLayoutGuide.snp.bottom)
                $0.width.equalTo(sv.frameLayoutGuide.snp.width).priority(.low)
            }
        }
    
    let tagTextField = UITextField()
        .then {
            $0.textColor = .iconDefault
            $0.font = .subTitle2
            $0.placeholder = "원하는 태그를 입력하고 enter를 눌러주세요."
            $0.backgroundColor = .clear
        }
    
    lazy var tagFromTextFieldCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = CGSize(width: 60, height: 30)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MyPoseCustomTagCell.self, forCellWithReuseIdentifier: MyPoseCustomTagCell.identifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    lazy var registeredImageView = UIImageView(image: self.registeredImage)
        .then {
            $0.contentMode = .scaleAspectFit
        }
    
    let imageLabel = UILabel()
        .then {
            $0.text = "등록된 이미지"
            $0.textColor = .textTertiary
            $0.font = .caption
        }
    
    let expandButton = UIButton(type: .system)
        .then {
            $0.setImage(ImageLiteral.imgExpand.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.backgroundColor = .dimmed30
        }
    
    let nextButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "다음", image: nil)
    
    // MARK: - Properties
    let registeredImage: UIImage?
    
    let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    let tagItemsFromTextField = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    
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
        view.addSubViews([mainLabel, tagCollectionView, textFieldScrollView, registeredImageView, expandButton, imageLabel, nextButton])
        
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
        
        textFieldScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(tagCollectionView.snp.bottom).offset(28)
            make.height.equalTo(56)
        }
        
        textFieldScrollView.subviews.first!.addSubViews([tagTextField, tagFromTextFieldCollectionView])
        
        tagFromTextFieldCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(textFieldScrollView).inset(12)
            make.leading.equalTo(textFieldScrollView).offset(16)
            make.centerY.equalTo(textFieldScrollView)
            make.width.equalTo(tagFromTextFieldCollectionView.collectionViewLayout.collectionViewContentSize.width)
        }
        
        tagTextField.snp.makeConstraints { make in
            make.leading.equalTo(tagFromTextFieldCollectionView.snp.trailing)
            make.height.equalTo(56)
            make.trailing.equalTo(textFieldScrollView.snp.trailing).offset(-16)
        }
        
        registeredImageView.snp.makeConstraints { make in
            make.top.equalTo(textFieldScrollView.snp.bottom).offset(87)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-50)
            make.width.equalTo(UIScreen.main.bounds.width / 3)
        }
        
        expandButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.center.equalTo(registeredImageView)
        }
        
        imageLabel.snp.makeConstraints { make in
            make.top.equalTo(registeredImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18.5)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configUI() {
        expandButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let absoluteOrigin: CGPoint? = self.registeredImageView.superview?.convert(self.registeredImageView.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
                let frame = CGRectMake(absoluteOrigin?.x ?? 0, absoluteOrigin?.y ?? 0, self.registeredImageView.frame.width, self.registeredImageView.frame.height)
                let vc = MyPoseImageDetailViewController(registeredImage: self.registeredImage, frame: frame)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
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
                        make.width.equalTo(owner.tagFromTextFieldCollectionView.frame.width + text.width(withConstrainedHeight: 32, font: .pretendard(.medium, ofSize: 14)) + 48)
                    }
                    owner.tagTextField.rx.text.onNext("")
                }
            })
            .disposed(by: disposeBag)
        
        /// OUTPUT: 커스텀 태그 아이템 바인딩
        tagItemsFromTextField.asDriver()
            .drive(tagFromTextFieldCollectionView.rx.items(cellIdentifier: MyPoseCustomTagCell.identifier, cellType: MyPoseCustomTagCell.self)) { _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
        .disposed(by: disposeBag)
        
        /// INPUT: 커스텀 태그 아이템 itemSelected 후 태그삭제 바인딩
        tagFromTextFieldCollectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                var items = self.tagItemsFromTextField.value
                let removedText = items.remove(at: indexPath.row)
                self.tagItemsFromTextField.accept(items)
                
                self.tagFromTextFieldCollectionView.snp.updateConstraints { make in
                    make.width.equalTo(self.tagFromTextFieldCollectionView.frame.width - removedText.title.value.width(withConstrainedHeight: 32, font: .pretendard(.medium, ofSize: 14)) - 48)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tagTextField.endEditing(true)
    }
}

extension MyPoseTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 30)
    }
}
