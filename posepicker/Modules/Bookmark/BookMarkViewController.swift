//
//  BookMarkViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

class BookMarkViewController: BaseViewController {
    
    // MARK: - Subviews
    
    let emptyView = EmptyBookmarkView()
    
    lazy var bookmarkCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.pinterestLayout)
        cv.register(BookmarkFeedCell.self, forCellWithReuseIdentifier: BookmarkFeedCell.identifier)
        cv.register(BookmarkEmptyView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkEmptyView.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    lazy var pinterestLayout = PinterestLayout()
        .then {
            $0.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: 50)
            $0.delegate = self
            $0.scrollDirection = .vertical
        }
    
    // MARK: - Properties
    var viewModel: BookMarkViewModel
    var coordinator: RootCoordinator
    
    let viewDidLoadTrigger = PublishSubject<Void>()
    let nextPageTrigger = PublishSubject<Void>()
    
    // MARK: - Initialization
    
    init(viewModel: BookMarkViewModel, coordinator: RootCoordinator) {
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
        viewDidLoadTrigger.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([emptyView])
        
        emptyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(52)
            make.height.equalTo(170)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(80)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "북마크"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = .bgWhite
        
        /// 뒤로가기 버튼 탭
        emptyView.toPoseFeedButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.coordinator.moveWithPage(page: .posefeed, direction: .reverse)
            })
            .disposed(by: disposeBag)
        
        /// 북마크 무한스크롤
//        poseFeedCollectionView.rx.contentOffset
//            .subscribe(onNext: { [unowned self] in
//                if $0.y > self.poseFeedCollectionView.contentSize.height - self.poseFeedCollectionView.bounds.size.height && !self.viewModel.isLoading && !self.viewModel.isLast {
//                    self.nextPageRequestTrigger.onNext(())
//                }
//            })
//            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let input = BookMarkViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger, nextPageTrigger: nextPageTrigger)
        let output = viewModel.transform(input: input)
        
        output.sectionItems
            .bind(to: bookmarkCollectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension BookMarkViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bookmarkCollectionView {
            return viewModel.filteredContentSizes.value[indexPath.item]
        }
        return CGSize(width: 60, height: 30)
    }
}


extension BookMarkViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return viewModel.filteredContentSizes.value[indexPath.item].height
        } else {
            return viewModel.recommendedContentsSizes.value[indexPath.item].height
        }
    }
}
