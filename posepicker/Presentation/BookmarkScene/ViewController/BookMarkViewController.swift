//
//  BookMarkViewController.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

class BookMarkViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews
    
    lazy var bookmarkCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.pinterestLayout)
        cv.register(BookmarkFeedCell.self, forCellWithReuseIdentifier: BookmarkFeedCell.identifier)
        cv.register(BookmarkEmptyView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkEmptyView.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        cv.backgroundColor = .bgWhite
        return cv
    }()
    
    lazy var pinterestLayout = PinterestLayout()
        .then {
            $0.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: 50)
            $0.delegate = self
            $0.scrollDirection = .vertical
        }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    // MARK: - Properties
    var viewModel: BookmarkViewModel?
    
//    let viewDidLoadTrigger = PublishSubject<Void>()
    let nextPageTrigger = PublishSubject<Void>()
    let bookmarkCheckObservable = PublishSubject<(Int, Bool)>()
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    private let bookmarkContentSizes = BehaviorRelay<[CGSize]>(value: [])
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([bookmarkCollectionView, loadingIndicator])
        
        bookmarkCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(-50)
            make.centerX.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        self.navigationItem.title = "북마크"
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .bgWhite
        
        /// 북마크 무한스크롤
//        bookmarkCollectionView.rx.contentOffset
//            .subscribe(onNext: { [unowned self] in
//                if $0.y > self.bookmarkCollectionView.contentSize.height - self.bookmarkCollectionView.bounds.size.height && !self.viewModel.isLoading && !self.viewModel.isLast {
//                    self.nextPageTrigger.onNext(())
//                }
//            })
//            .disposed(by: disposeBag)
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        view.addSubview(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubview(bookmarkCollectionView)
        bookmarkCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
        let input = BookmarkViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
//        let input = BookMarkViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger, nextPageTrigger: nextPageTrigger, bookmarkSelection: bookmarkCollectionView.rx.modelSelected(BookmarkFeedCellViewModel.self), bookmarkFromPoseId: bookmarkCheckObservable)
//        let output = viewModel.transform(input: input)
//        
//        output.sectionItems
//            .bind(to: bookmarkCollectionView.rx.items(dataSource: viewModel.dataSource))
//            .disposed(by: disposeBag)
//        
//        output.isLoading.asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [unowned self] in
//                guard let flowLayout = self.bookmarkCollectionView.collectionViewLayout as? PinterestLayout else { return }
//                flowLayout.isLoading.accept($0)
//                self.loadingIndicator.isHidden = !$0
//            })
//            .disposed(by: disposeBag)
//        
//        output.transitionToPoseFeed
//            .subscribe(onNext: { [weak self] in
//                self?.coordinator?.moveToPoseFeed()
//            })
//            .disposed(by: disposeBag)
//        
//        output.bookmarkDetailViewPush
//            .drive(onNext: { [unowned self] in
//                guard let viewModel = $0 else { return }
//                guard let coordinator = self.coordinator else { return }
//                coordinator.pushBookmarkDetailView(viewController: BookmarkDetailViewController(viewModel: viewModel, coordinator: coordinator))
//            })
//            .disposed(by: disposeBag)
//        
//        viewModel.bookmarkButtonTapped
//            .subscribe(onNext: { [unowned self] in
//                guard let coordinator = self.coordinator else { return }
//                coordinator.triggerBookmarkFromPoseId(poseId: $0, bookmarkCheck: true)
//                self.bookmarkCheckObservable.onNext(($0, false))
//            })
//            .disposed(by: disposeBag)
//        
//        viewModel.bookmarkRemoveButtonTapped
//            .subscribe(onNext: { [unowned self] in
//                guard let coordinator = self.coordinator else { return }
//                coordinator.triggerBookmarkFromPoseId(poseId: $0, bookmarkCheck: false)
//                self.bookmarkCheckObservable.onNext(($0, true))
//            })
//            .disposed(by: disposeBag)
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
            return bookmarkContentSizes.value[indexPath.item]
        }
        return CGSize(width: 60, height: 30)
    }
}


extension BookMarkViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return bookmarkContentSizes.value[indexPath.item].height
    }
}

private extension BookMarkViewController {
    func configureOutput(_ output: BookmarkViewModel.Output?) {
        output?.bookmarkContents
            .asDriver()
            .drive(bookmarkCollectionView.rx.items(cellIdentifier: BookmarkFeedCell.identifier, cellType: BookmarkFeedCell.self)) { _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        output?.bookmarkContentSizes
            .subscribe(onNext: { [weak self] in
                self?.bookmarkContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
    }
}
