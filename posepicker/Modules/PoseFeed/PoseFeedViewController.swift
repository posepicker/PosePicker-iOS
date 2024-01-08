//
//  PoseFeedViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class PoseFeedViewController: BaseViewController {
    
    // MARK: - Subviews
    let filterButton = UIButton(type: .system)
        .then {
            $0.setTitleColor(.textSecondary, for: .normal)
            var configuration = UIButton.Configuration.filled()
            var attrString = AttributedString("필터")
            attrString.font = .pretendard(.medium, ofSize: 14)
            attrString.foregroundColor = UIColor.textSecondary
            configuration.baseBackgroundColor = .bgSubWhite
            configuration.imagePadding = 10
            configuration.attributedTitle = attrString
            $0.configuration = configuration
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.semanticContentAttribute = .forceRightToLeft
            $0.setImage(ImageLiteral.imgCaretDown.withTintColor(.textSecondary).withRenderingMode(.alwaysOriginal), for: .normal)
        }
    
    let filterDivider = UIImageView(image: ImageLiteral.imgDividerVertical.withRenderingMode(.alwaysOriginal))
    
    lazy var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = CGSize(width: 60, height: 30)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.register(RegisteredFilterCell.self, forCellWithReuseIdentifier: RegisteredFilterCell.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    lazy var poseFeedCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.pinterestLayout)
        cv.register(PoseFeedPhotoCell.self, forCellWithReuseIdentifier: PoseFeedPhotoCell.identifier)
        cv.register(PoseFeedHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedHeader.identifier)
        cv.register(PoseFeedEmptyView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedEmptyView.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    lazy var pinterestLayout = PinterestLayout()
        .then {
            $0.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: 50)
            $0.delegate = self
            $0.scrollDirection = .vertical
        }
    
    let supplementLabel = UILabel()
        .then {
            $0.textAlignment = .left
            $0.textColor = .textPrimary
            $0.font = .h4
            $0.text = "이런 포즈는 어때요?"
        }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    // MARK: - Properties
    
    var viewModel: PoseFeedViewModel
    var coordinator: PoseFeedCoordinator
    let requestAllPoseTrigger = PublishSubject<Void>()

    let nextPageRequestTrigger = PublishSubject<Void>()
    let modalDismissWithTag = PublishSubject<String>() // 상세 페이지에서 태그 tap과 함께 dismiss 트리거
    let registerButtonTapped = PublishSubject<Void>()
    
    let appleIdentityTokenTrigger = PublishSubject<String>()
    let kakaoEmailTrigger = PublishSubject<String>()
    let kakaoIdTrigger = PublishSubject<Int64>()

    // MARK: - Initialization
    
    init(viewModel: PoseFeedViewModel, coordinator: PoseFeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAllPoseTrigger.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([filterButton, filterDivider, filterCollectionView, poseFeedCollectionView, supplementLabel, loadingIndicator])
        
        filterButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        
        filterDivider.snp.makeConstraints { make in
            make.leading.equalTo(filterButton.snp.trailing).offset(8)
            make.top.bottom.equalTo(filterButton).inset(8)
        }
        
        filterCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(filterButton)
            make.leading.equalTo(filterDivider.snp.trailing).offset(8)
            make.trailing.equalTo(view).offset(-20)
        }
        
        poseFeedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(filterButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
        
        poseFeedCollectionView.rx.contentOffset
            .subscribe(onNext: { [unowned self] in
                if $0.y > self.poseFeedCollectionView.contentSize.height - self.poseFeedCollectionView.bounds.size.height && !self.viewModel.isLoading && !self.viewModel.isLast {
                    self.nextPageRequestTrigger.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.presentLoginPopUp
            .subscribe(onNext: { [unowned self] in
                let popUpVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
                popUpVC.modalTransitionStyle = .crossDissolve
                popUpVC.modalPresentationStyle = .overFullScreen
                self.present(popUpVC, animated: true)
                
                popUpVC.appleIdentityToken
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.appleIdentityTokenTrigger.onNext($0)
                    })
                    .disposed(by: self.disposeBag)
                
                popUpVC.email
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.kakaoEmailTrigger.onNext($0)
                    })
                    .disposed(by: disposeBag)
                
                popUpVC.kakaoId
                    .compactMap { $0 }
                    .subscribe(onNext: { [unowned self] in
                        self.kakaoIdTrigger.onNext($0)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        coordinator.poseFeedFilterViewController.submitButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.registerButtonTapped.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = PoseFeedViewModel.Input(filterButtonTapped: filterButton.rx.controlEvent(.touchUpInside), tagItems: Observable.combineLatest(coordinator.poseFeedFilterViewController.selectedHeadCount, coordinator.poseFeedFilterViewController.selectedFrameCount, coordinator.poseFeedFilterViewController.selectedTags, coordinator.poseFeedFilterViewController.registeredSubTag), filterTagSelection: filterCollectionView.rx.modelSelected(RegisteredFilterCellViewModel.self).asObservable(), filterRegisterCompleted: registerButtonTapped, poseFeedFilterViewIsPresenting: coordinator.poseFeedFilterViewController.isPresenting.asObservable(), requestAllPoseTrigger: requestAllPoseTrigger, poseFeedSelection: poseFeedCollectionView.rx.modelSelected(PoseFeedPhotoCellViewModel.self), nextPageRequestTrigger: nextPageRequestTrigger, modalDismissWithTag: modalDismissWithTag, appleIdentityTokenTrigger: appleIdentityTokenTrigger, kakaoLoginTrigger: Observable.combineLatest(kakaoEmailTrigger, kakaoIdTrigger))
    
        let output = viewModel.transform(input: input)
        
        output.presentModal
            .drive(onNext: { [unowned self] in
                self.coordinator.poseFeedFilterViewController.isPresenting.accept(true)
                self.coordinator.presentModal()
            })
            .disposed(by: disposeBag)
        
        output.filterTagItems
            .drive(filterCollectionView.rx.items(cellIdentifier: RegisteredFilterCell.identifier, cellType: RegisteredFilterCell.self)) {  _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        output.deleteTargetCountTag
            .drive(onNext: { [unowned self] in
                guard let tag = $0 else { return }
                switch tag {
                case .head:
                    self.coordinator.poseFeedFilterViewController.countTagRemoveTrigger.onNext(.head)
                case .frame:
                    self.coordinator.poseFeedFilterViewController.countTagRemoveTrigger.onNext(.frame)
                }
            })
            .disposed(by: disposeBag)
        
        output.deleteTargetFilterTag
            .drive(onNext: { [unowned self] in
                guard let removeTarget = $0 else { return }
                self.coordinator.poseFeedFilterViewController.filterTagRemoveTrigger.onNext(removeTarget)
            })
            .disposed(by: disposeBag)
        
        output.deleteSubTag
            .drive(onNext: { [unowned self] in
                self.coordinator.poseFeedFilterViewController.subTagRemoveTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        output.sectionItems
            .bind(to: poseFeedCollectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        output.poseDetailViewPush
            .drive(onNext: { [unowned self] in
                guard let viewModel = $0 else { return }
                self.coordinator.pushDetailView(viewController: PoseDetailViewController(viewModel: viewModel, coordinator: self.coordinator))
            })
            .disposed(by: disposeBag)
        
        output.isLoading.asDriver(onErrorJustReturn: false)
            .drive(onNext: { [unowned self] in
                guard let flowLayout = self.poseFeedCollectionView.collectionViewLayout as? PinterestLayout else { return }
                flowLayout.isLoading.accept($0)
                self.loadingIndicator.isHidden = !$0
            })
            .disposed(by: disposeBag)
        
        output.dismissLoginView
            .subscribe(onNext: { [unowned self] in
                guard let popupVC = self.presentedViewController as? PopUpViewController,
                      let _ = popupVC.popUpView as? LoginPopUpView else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PoseFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == poseFeedCollectionView {
            return viewModel.filteredContentSizes.value[indexPath.item]
        }
        return CGSize(width: 60, height: 30)
    }
}

extension PoseFeedViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return viewModel.filteredContentSizes.value[indexPath.item].height
        } else {
            return viewModel.recommendedContentsSizes.value[indexPath.item].height
        }
    }
}
