//
//  MyPoseTagViewController.swift
//  posepicker
//
//  Created by 박경준 on 2/23/24.
//

import UIKit
import RxSwift
import RxCocoa

class PoseUploadTagViewController: BaseViewController {
    // MARK: - Subviews
    let scrollView = UIScrollView()
        .then { sv in
            let view = UIView()
            sv.addSubview(view)
            view.snp.makeConstraints {
                $0.top.equalTo(sv.contentLayoutGuide.snp.top)
                $0.leading.equalTo(sv.contentLayoutGuide.snp.leading)
                $0.trailing.equalTo(sv.contentLayoutGuide.snp.trailing)
                $0.bottom.equalTo(sv.contentLayoutGuide.snp.bottom)

                $0.leading.equalTo(sv.frameLayoutGuide.snp.leading)
                $0.trailing.equalTo(sv.frameLayoutGuide.snp.trailing)
                $0.height.equalTo(sv.frameLayoutGuide.snp.height).priority(.low)
            }
        }
    
    let mainLabel = UILabel()
        .then {
            let attributedText = NSMutableAttributedString(string: "최소 3개 이상", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.bold, ofSize: 32)])
            attributedText.append(NSAttributedString(string: "\n태그를 선택해주세요!", attributes: [NSAttributedString.Key.font: UIFont.pretendard(.medium, ofSize: 32)]))
            $0.numberOfLines = 0
            $0.attributedText = attributedText
            $0.textAlignment = .left
        }
    
    let tagCountLabel = UILabel()
        .then {
            $0.text = "(0/10)"
            $0.textColor = .textTertiary
            $0.font = .caption
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
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 6
            $0.contentMode = .scaleAspectFill
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
    let inputCompleted = BehaviorRelay<Bool>(value: false)
    
    let tagItems = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    let tagItemsFromTextField = BehaviorRelay<[PoseFeedFilterCellViewModel]>(value: [])
    let selectedTagCount = BehaviorRelay<Int>(value: 0)
    
    var viewModel: PoseUploadTagViewModel?
    
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
        view.addSubViews([scrollView, nextButton])
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top)
        }
        
        scrollView.subviews.first!.addSubViews([mainLabel, tagCountLabel, tagCollectionView, textFieldScrollView, registeredImageView, expandButton, imageLabel])
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(80)
        }
        
        tagCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainLabel.snp.trailing).offset(10)
            make.firstBaseline.equalTo(mainLabel.snp.lastBaseline)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(UIScreen.main.isLongerThan800pt ? 36 : 18)
            make.leading.equalTo(mainLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(UIScreen.main.isLongerThan800pt ? 84 : 130)
        }
        
        textFieldScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(tagCollectionView.snp.bottom).offset(UIScreen.main.isLongerThan800pt ? 28 : 0)
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
            make.centerY.equalTo(textFieldScrollView)
            make.leading.equalTo(tagFromTextFieldCollectionView.snp.trailing)
            make.height.equalTo(56)
            make.trailing.equalTo(textFieldScrollView.snp.trailing).offset(-16)
        }
        
        registeredImageView.snp.makeConstraints { make in
            make.top.equalTo(textFieldScrollView.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(160)
        }
        
        expandButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.center.equalTo(registeredImageView)
        }
        
        imageLabel.snp.makeConstraints { make in
            make.top.equalTo(registeredImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
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
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
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
                    
                    // 커스텀 태그 텍스트필드에서 입력된 태그가 기본태그에 포함되는 경우 체크해주고 리턴
                    if owner.tagItems.value.contains(where: {
                        $0.title.value == text
                    }) {
                        let items = owner.tagItems.value
                        if let index = items.firstIndex(where: { $0.title.value == text }) {
                            items[index].isSelected.accept(true)
                            owner.tagItems.accept(items)
                        }
                        self.tagTextField.rx.text.onNext("")
                        return
                    }
                    
                    // 입력 태그가 이미 중복이면 리턴
                    if owner.tagItemsFromTextField.value.contains(where: {
                        $0.title.value == text
                    }) {
                        owner.tagTextField.rx.text.onNext("")
                        return
                    }
                    
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
        
        // +) 텍스트필드 10자 이상인 경우 제한
        tagTextField.rx.text.orEmpty.map { String($0.prefix(10)) }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] str in
                self?.tagTextField.text = str
                let selectedTagCount = self?.selectedTagCount.value ?? 0
                if str.count >= 10 || selectedTagCount >= 10 {
                    // 열개인 경우 텍스트필드 비활성화
                    self?.textFieldScrollView.layer.borderColor = UIColor.red600.cgColor
                } else {
                    self?.textFieldScrollView.layer.borderColor = UIColor.borderDefault.cgColor
                }
                
                if selectedTagCount >= 10 {
                    self?.tagTextField.isEnabled = false
                } else {
                    self?.tagTextField.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        // 3. 스페이스바 입력후 태그 생성
        tagTextField.rx.text
            .asDriver()
            .drive(onNext: { [weak self] str in
                if let str = str, str.last == " " {
                    guard let self = self else { return }
                    
                    // 입력문자 값복사해야 텍스트필드 반응 안함
                    var str = str; _ = str.popLast()
                    
                    // 스페이스 입력으로 인한 공백 제외하고 입력 없으면 리턴
                    if str.isEmpty {
                        self.tagTextField.rx.text.onNext("")
                        return
                    }
                    
                    // 커스텀 태그 텍스트필드에서 입력된 태그가 기본태그에 포함되는 경우 체크해주고 리턴
                    if self.tagItems.value.contains(where: {
                        $0.title.value == str
                    }) {
                        let items = self.tagItems.value
                        if let index = items.firstIndex(where: { $0.title.value == str }) {
                            items[index].isSelected.accept(true)
                            self.tagItems.accept(items)
                        }
                        self.tagTextField.rx.text.onNext("")
                        return
                    }
                    
                    // 입력 태그가 이미 중복이면 리턴
                    if self.tagItemsFromTextField.value.contains(where: {
                        $0.title.value == str
                    }) {
                        self.tagTextField.rx.text.onNext("")
                        return
                    }
                    
                    // 커스텀태그 뷰모델 생성
                    let vm = PoseFeedFilterCellViewModel(title: str)
                    vm.isSelected.accept(true)
                    
                    // 태그 생성
                    self.tagItemsFromTextField.accept(self.tagItemsFromTextField.value + [vm])
                    self.tagFromTextFieldCollectionView.snp.updateConstraints { make in
                        make.width.equalTo(self.tagFromTextFieldCollectionView.frame.width + str.width(withConstrainedHeight: 32, font: .pretendard(.medium, ofSize: 14)) + 48)
                    }
                    self.tagTextField.rx.text.onNext("")
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
        
        /// INPUT: 기본태그 선택 후 셀렉팅효과 추가
        tagCollectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let items = tagItems.value
                
                // 태그가 열개 채워진 상태일때는 태그 선택 더 안되게 리턴
                if self.selectedTagCount.value >= 10 && !items[indexPath.row].isSelected.value {
                    return
                }
                
                items[indexPath.row].isSelected.accept(!items[indexPath.row].isSelected.value)
                self.tagItems.accept(items)
            })
            .disposed(by: disposeBag)
        
        // 태그아이템 갯수 총합 (일반 + 커스텀) 후 UI 변경
        Observable.combineLatest(tagItems, tagItemsFromTextField)
            .flatMapLatest { [weak self] items, itemsFromTextfield -> Observable<Bool> in
                let combinedItems = items + itemsFromTextfield
                var count = 0
                combinedItems.forEach { item in
                    if item.isSelected.value {
                        count += 1
                        // 카운트 10개 이상인 경우 숫자변경 X
                        self?.selectedTagCount.accept(count)
                    }
                }
                self?.tagCountLabel.text = count >= 10 ? "(10/10)" : "(\(count)/10)"
                self?.inputCompleted.accept(count >= 3)
                return BehaviorRelay<Bool>(value: count >= 10).asObservable()
            }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isOver in // 태그 총합이 열개 이상인가
                self?.setTextFieldBorderColor(isOver: isOver)
                
                if !isOver && self?.tagTextField.text?.count ?? 0 >= 10 {
                    self?.textFieldScrollView.layer.borderColor = UIColor.red600.cgColor
                } else if !isOver && self?.tagTextField.text?.count ?? 0 < 10 {
                    self?.textFieldScrollView.layer.borderColor = UIColor.borderDefault.cgColor
                }
            })
            .disposed(by: disposeBag)
        
        // 전체 태그 갯수가 세개 이상인 경우 다음 페이지로 넘어갈 수 있도록
        inputCompleted.asDriver()
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.nextButton.status.accept(.defaultStatus)
                } else {
                    self?.nextButton.status.accept(.disabled)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tagTextField.endEditing(true)
    }
    
    func setTextFieldBorderColor(isOver: Bool, _ forOnlyUI: Bool? = nil) {
        self.tagCountLabel.textColor = isOver ? .warningDark : .textTertiary
        
        if isOver {
            // 열개인 경우 텍스트필드 비활성화
            self.tagTextField.isEnabled = false
            self.textFieldScrollView.layer.borderColor = UIColor.red600.cgColor
        } else {
            self.textFieldScrollView.layer.borderColor = UIColor.borderDefault.cgColor
            self.tagTextField.isEnabled = true
        }
    }
    
    // MARK: - Objc function
    @objc
    func scrollViewTapped() {
        tagTextField.endEditing(true)
    }
}

extension PoseUploadTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 30)
    }
}
