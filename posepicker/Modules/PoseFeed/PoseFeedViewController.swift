//
//  PoseFeedViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

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
        cv.delegate = self
        return cv
    }()
    
    
    
    // MARK: - Properties
    
    var viewModel: PoseFeedViewModel
    var coordinator: PoseFeedCoordinator
    
    // MARK: - Initialization
    
    init(viewModel: PoseFeedViewModel, coordinator: PoseFeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([filterButton, filterDivider, filterCollectionView])
        
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
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
    }
    
    override func bindViewModel() {
        let input = PoseFeedViewModel.Input(filterButtonTapped: filterButton.rx.controlEvent(.touchUpInside), tagItems: Observable.combineLatest(coordinator.poseFeedFilterViewController.selectedHeadCount, coordinator.poseFeedFilterViewController.selectedFrameCount, coordinator.poseFeedFilterViewController.selectedTags), filterTagSelection: filterCollectionView.rx.modelSelected(RegisteredFilterCellViewModel.self).asObservable(), filterRegisterCompleted: coordinator.poseFeedFilterViewController.submitButton.rx.controlEvent(.touchUpInside), poseFeedFilterViewIsPresenting: coordinator.poseFeedFilterViewController.isPresenting.asObservable(), filterReset: coordinator.poseFeedFilterViewController.resetButton.rx.tap)
        
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
    }
}

extension PoseFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 30)
    }
}
