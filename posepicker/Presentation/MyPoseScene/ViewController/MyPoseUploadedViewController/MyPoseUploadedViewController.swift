//
//  MyPoseUploadedViewController.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift
import RxRelay

class MyPoseUploadedViewController: BaseViewController {

    // MARK: - Subviews
    
    lazy var uploadedPoseCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.pinterestLayout)
        cv.register(BookmarkFeedCell.self, forCellWithReuseIdentifier: BookmarkFeedCell.uploadedIdentifier)
        cv.register(BookmarkEmptyView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkEmptyView.uploadedIdentifier)
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
            $0.layer.zPosition = 999
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    let refreshControl = UIRefreshControl()
        .then {
            $0.tintColor = .mainViolet
        }
    
    // MARK: - Properties
    var viewModel: MyPoseUploadedViewModel?
    
    let nextPageTrigger = PublishSubject<Void>()
    let contentsUpdateEvent = PublishSubject<Void>()
    let removeAllContentsTrigger = PublishSubject<Void>()
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    private let uploadedContentSizes = BehaviorRelay<[CGSize]>(value: [])
    private let bookmarkButtonTapEvent = PublishSubject<(Int, Bool)>()
    private let infiniteScrollEvent = PublishSubject<Void>()
    private var viewDidLoaded = false
    private var viewDidAppeared = false
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoaded = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewDidLoaded && viewDidAppeared {
            return
        }
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([uploadedPoseCollectionView, loadingIndicator])
        
        uploadedPoseCollectionView.snp.makeConstraints { make in
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
        view.backgroundColor = .bgWhite
        self.uploadedPoseCollectionView.refreshControl = refreshControl
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        view.addSubview(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubview(uploadedPoseCollectionView)
        uploadedPoseCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
        let input = MyPoseUploadedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            bookmarkCellTapEvent: uploadedPoseCollectionView.rx.modelSelected(BookmarkFeedCellViewModel.self).asObservable(),
            bookmarkButtonTapEvent: bookmarkButtonTapEvent,
            infiniteScrollEvent: infiniteScrollEvent,
            contentsUpdateEvent: contentsUpdateEvent,
            refreshEvent: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            removeAllContentsEvent: removeAllContentsTrigger
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        
        configureOutput(output)
    }
}

extension MyPoseUploadedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == uploadedPoseCollectionView {
            return uploadedContentSizes.value[indexPath.item]
        }
        return CGSize(width: 60, height: 30)
    }
}


extension MyPoseUploadedViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return uploadedContentSizes.value[indexPath.item].height
    }
}

private extension MyPoseUploadedViewController {
    func configureOutput(_ output: MyPoseUploadedViewModel.Output?) {
        /// 무한스크롤 로직
        /// Reentry anomaly 에러 해결 - 구독중에 복잡한 값 방출
        uploadedPoseCollectionView.rx.contentOffset
            .asDriver()
            .drive(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                guard let output = output else { return }
                if contentOffset.y > 300
                    && contentOffset.y + 300 > self.uploadedPoseCollectionView.contentSize.height - self.uploadedPoseCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                    return
                }
                
                if contentOffset.y > self.uploadedPoseCollectionView.contentSize.height - self.uploadedPoseCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        output?.uploadedContents
            .asDriver()
            .drive(uploadedPoseCollectionView.rx.items(cellIdentifier: BookmarkFeedCell.uploadedIdentifier, cellType: BookmarkFeedCell.self)) { [weak self] _, viewModel, cell in
                guard let self = self else { return }
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
                cell.bookmarkButton.rx.tap
                    .map { viewModel.poseId.value }
                    .subscribe(onNext: {
                        self.bookmarkButtonTapEvent.onNext(($0, viewModel.bookmarkCheck.value))
                        viewModel.bookmarkCheck.accept(!viewModel.bookmarkCheck.value)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output?.uploadedContentSizes
            .subscribe(onNext: { [weak self] in
                self?.uploadedContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        output?.isLoading
            .map { !$0 }
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        output?.refreshEnded
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
}
