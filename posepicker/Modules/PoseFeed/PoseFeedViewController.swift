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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PoseFeedPhotoCell.self, forCellWithReuseIdentifier: PoseFeedPhotoCell.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    // MARK: - Properties
    
    var viewModel: PoseFeedViewModel
    var coordinator: PoseFeedCoordinator
    let viewDidAppearTrigger = PublishSubject<Void>()
    var intrinsicContentSizeUpdateTrigger = PublishSubject<Observable<CGSize>>()

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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearTrigger.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([filterButton, filterDivider, filterCollectionView, poseFeedCollectionView])
        
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
            make.top.equalTo(filterButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
    }
    
    override func bindViewModel() {
        let input = PoseFeedViewModel.Input(filterButtonTapped: filterButton.rx.controlEvent(.touchUpInside), tagItems: Observable.combineLatest(coordinator.poseFeedFilterViewController.selectedHeadCount, coordinator.poseFeedFilterViewController.selectedFrameCount, coordinator.poseFeedFilterViewController.selectedTags), filterTagSelection: filterCollectionView.rx.modelSelected(RegisteredFilterCellViewModel.self).asObservable(), filterRegisterCompleted: coordinator.poseFeedFilterViewController.submitButton.rx.controlEvent(.touchUpInside), poseFeedFilterViewIsPresenting: coordinator.poseFeedFilterViewController.isPresenting.asObservable(), filterReset: coordinator.poseFeedFilterViewController.resetButton.rx.tap, viewDidAppearTrigger: viewDidAppearTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.presentModal
            .drive(onNext: { [unowned self] in
                self.coordinator.poseFeedFilterViewController.isPresenting.accept(true)
                self.coordinator.presentModal()
            })
            .disposed(by: disposeBag)
        
        output.filterTagItems
            .drive(filterCollectionView.rx.items(cellIdentifier: RegisteredFilterCell.identifier, cellType: RegisteredFilterCell.self)) {  _, viewModel, cell in
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
        
        output.photoCellItems
            .drive(poseFeedCollectionView.rx.items(cellIdentifier: PoseFeedPhotoCell.identifier, cellType: PoseFeedPhotoCell.self)) { row, viewModel, cell in
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        poseFeedCollectionView.updateCollectionViewHeight()
    }
}

extension PoseFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == poseFeedCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PoseFeedPhotoCell.identifier, for: indexPath) as? PoseFeedPhotoCell else { return CGSize(width: 60, height: 30) }
            

            return CGSize(width: 60, height: 30)   
        }
        
        return CGSize(width: 60, height: 30)
    }
}
