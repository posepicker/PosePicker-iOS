//
//  PoseFeedFilterViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

//import UIKit
//import RxCocoa
//import RxSwift
//
//class PoseFeedFilterViewController: BaseViewController {
//
//    // MARK: - Subviews
//    let closeButton = UIButton(type: .system)
//        .then {
//            $0.setImage(ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
//    
//    let headCountLabel = UILabel()
//        .then {
//            $0.font = .pretendard(.medium, ofSize: 14)
//            $0.text = "인원 수"
//        }
//    
//    let headCountSelection = BasicSelection(buttonGroup: ["전체", "1인", "2인", "3인", "4인", "5인+"])
//    
//    let frameCountLabel = UILabel()
//        .then {
//            $0.text = "프레임 수"
//            $0.font = .pretendard(.medium, ofSize: 14)
//        }
//    
//    let frameCountSelection = BasicSelection(buttonGroup: ["전체", "1컷", "3컷", "4컷", "6컷", "8컷+"])
//    
//    let tagLabel = UILabel()
//        .then {
//            $0.font = .pretendard(.medium, ofSize: 14)
//            $0.text = "태그"
//        }
//    
//    let tagCollectionView: UICollectionView = {
//        let layout = LeftAlignedCollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 4
//        layout.minimumLineSpacing = 8
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .bgWhite
//        cv.register(PoseFeedFilterCell.self, forCellWithReuseIdentifier: PoseFeedFilterCell.identifier)
//        return cv
//    }()
//    
//    let resetButton = PosePickButton(status: .defaultStatus, isFill: false, position: .left, buttonTitle: "필터 초기화", image: ImageLiteral.imgRestart24.resize(to: CGSize(width: 20, height: 20)))
//    
//    let submitButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "포즈보기", image: nil)
//    
//    // MARK: - Properties
//    
//    var viewModel: PoseFeedFilterViewModel
//    
//    let selectedHeadCount = BehaviorRelay<PeopleCountTags>(value: .all)
//    let selectedFrameCount = BehaviorRelay<FrameCountTags>(value: .allCut)
//    let selectedTags = BehaviorRelay<[FilterTags]>(value: [])
//    let registeredSubTag = BehaviorRelay<String?>(value: nil) // 주요 태그정보가 아닌 서브태그
//    let filteredTagAfterDismiss = BehaviorRelay<FilterTags?>(value: nil)
//    
//    var detailViewDismissTrigger = PublishSubject<Void>()
//    
//    var isPresenting = BehaviorRelay<Bool>(value: false)
//    var cancelTrigger = PublishSubject<Void>()
//    var dismissState = BehaviorRelay<PoseFeedFilterViewModel.DismissState>(value: .normal)
//    var viewWillDisappearTrigger = PublishSubject<Void>()
//    
//    let countTagRemoveTrigger = PublishSubject<PoseFeedViewModel.CountTagType>()
//    let filterTagRemoveTrigger = PublishSubject<FilterTags>()
//    let subTagRemoveTrigger = PublishSubject<Void>()
//    let resetConfirmed = PublishSubject<Void>() // 팝업창 한번 거쳐서 이벤트 방출하기 위함
//    
//    // MARK: - Initialization
//    
//    init(viewModel: PoseFeedFilterViewModel) {
//        self.viewModel = viewModel
//        super.init()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Life Cycles
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        dismissState.accept(.normal)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        isPresenting.accept(false)
//        viewWillDisappearTrigger.onNext(())
//    }
//    
//    // MARK: - Functions
//    
//    override func render() {
//        view.addSubViews([closeButton, headCountLabel, headCountSelection, frameCountLabel, frameCountSelection, tagLabel, tagCollectionView, resetButton, submitButton])
//    
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(view.snp.top).offset(28)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//        
//        headCountLabel.snp.makeConstraints { make in
//            make.top.equalTo(closeButton.snp.bottom).offset(12)
//            make.leading.equalToSuperview().offset(20)
//        }
//        
//        headCountSelection.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(headCountLabel.snp.bottom).offset(8)
//            make.height.equalTo(40)
//        }
//        
//        frameCountLabel.snp.makeConstraints { make in
//            make.top.equalTo(headCountSelection.snp.bottom).offset(20)
//            make.leading.equalTo(headCountLabel)
//        }
//        
//        frameCountSelection.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(frameCountLabel.snp.bottom).offset(8)
//            make.height.equalTo(40)
//        }
//        
//        tagLabel.snp.makeConstraints { make in
//            make.top.equalTo(frameCountSelection.snp.bottom).offset(20)
//            make.leading.equalTo(frameCountLabel)
//        }
//        
//        tagCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(tagLabel.snp.bottom).offset(8)
//            make.leading.equalTo(tagLabel)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(72)
//        }
//        
//        resetButton.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(20)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-36)
//            make.height.equalTo(54)
//            make.trailing.equalTo(view.snp.centerX).offset(-4)
//        }
//        
//        submitButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-20)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-36)
//            make.height.equalTo(54)
//            make.leading.equalTo(view.snp.centerX).offset(4)
//        }
//    }
//    
//    override func configUI() {
//        view.backgroundColor = .bgWhite
//        
//        closeButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] in
//                self.dismissState.accept(.normal)
//                self.cancelTrigger.onNext(())
//                self.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        submitButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] in
//                self.dismissState.accept(.save)
//                self.isPresenting.accept(false)
//                self.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    override func bindViewModel() {
//        let input = PoseFeedFilterViewModel.Input(headCountSelection: headCountSelection.buttonTapTrigger.asObservable(), frameCountSelection: frameCountSelection.buttonTapTrigger.asObservable(), tagSelection: tagCollectionView.rx.modelSelected(PoseFeedFilterCellViewModel.self).asObservable(), registeredSubTag: registeredSubTag, tagSelectCanceled: cancelTrigger.asObservable(), isPresenting: isPresenting, resetButtonTapped: resetConfirmed, dismissState: dismissState.asObservable(), viewWillDisappearTrigger: viewWillDisappearTrigger.asObservable(), countTagRemoveTrigger: countTagRemoveTrigger.asObservable(), filterTagRemoveTrigger: filterTagRemoveTrigger.asObservable(), subTagRemoveTrigger: subTagRemoveTrigger, detailViewDismissTrigger: detailViewDismissTrigger, filteredTagAfterDismiss: filteredTagAfterDismiss.asObservable())
//        
//        let output = viewModel.transform(input: input)
//        
//        /// 팝업 노출 로직 추가
//        resetButton.rx.tap.asDriver()
//            .drive(onNext: { [weak self] in
//                guard let self = self else { return }
//                let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: true)
//                guard let popupView = popupVC.popUpView as? PopUpView else { return }
//                popupView.alertText.accept("필터를 초기화하시겠습니까?")
//                popupVC.modalTransitionStyle = .crossDissolve
//                popupVC.modalPresentationStyle = .overFullScreen
//                
//                popupView.cancelButton.rx.tap.asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.dismiss(animated: true)
//                    })
//                    .disposed(by: self.disposeBag)
//                
//                popupView.confirmButton.rx.tap.asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.resetConfirmed.onNext(())
//                        self?.dismiss(animated: true)
//                    })
//                    .disposed(by: disposeBag)
//                
//                self.present(popupVC, animated: true)
//            })
//            .disposed(by: disposeBag)
//
//        output.tagItems
//            .drive(tagCollectionView.rx.items(cellIdentifier: PoseFeedFilterCell.identifier, cellType: PoseFeedFilterCell.self)) { _, viewModel, cell in
//                cell.disposeBag = DisposeBag()
//                cell.bind(to: viewModel)
//            }
//            .disposed(by: disposeBag)
//        
//        output.headCountTag
//            .drive(onNext: { [unowned self] in
//                self.headCountSelection.pressIndex.accept($0)
//                guard let headCountTag = PeopleCountTags.getTagFromTitle(title: self.headCountSelection.buttonGroup[$0]) else { return }
//                self.selectedHeadCount.accept(headCountTag)
//            })
//            .disposed(by: disposeBag)
//        
//        output.frameCountTag
//            .drive(onNext: { [unowned self] in
//                self.frameCountSelection.pressIndex.accept($0)
//                guard let frameCountTag = FrameCountTags.getTagFromTitle(title: self.frameCountSelection.buttonGroup[$0]) else { return }
//                self.selectedFrameCount.accept(frameCountTag)
//            })
//            .disposed(by: disposeBag)
//        
//        output.registeredTags
//            .drive(onNext: { [unowned self] in
//                self.selectedTags.accept($0)
//            })
//            .disposed(by: disposeBag)
//        
//        subTagRemoveTrigger
//            .subscribe(onNext: { [unowned self] in
//                self.registeredSubTag.accept(nil)
//            })
//            .disposed(by: disposeBag)
//        
//        tagCollectionView.updateCollectionViewHeight()
//    }
//}
