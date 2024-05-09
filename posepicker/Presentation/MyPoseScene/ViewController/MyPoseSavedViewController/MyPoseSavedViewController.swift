//
//  MyPoseSavedViewController.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import UIKit
import RxSwift
import RxRelay

class MyPoseSavedViewController: BaseViewController {

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
            $0.layer.zPosition = 999
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    // MARK: - Properties
    var viewModel: MyPoseSavedViewModel?
    
    let nextPageTrigger = PublishSubject<Void>()
    let contentsUpdateEvent = PublishSubject<Void>()
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    private let bookmarkContentSizes = BehaviorRelay<[CGSize]>(value: [])
    private let bookmarkButtonTapEvent = PublishSubject<(Int, Bool)>()
    private let infiniteScrollEvent = PublishSubject<Void>()
    
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
        view.backgroundColor = .bgWhite
        
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
        let input = MyPoseSavedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            bookmarkCellTapEvent: bookmarkCollectionView.rx.modelSelected(BookmarkFeedCellViewModel.self).asObservable(),
            bookmarkButtonTapEvent: bookmarkButtonTapEvent,
            infiniteScrollEvent: infiniteScrollEvent,
            contentsUpdateEvent: contentsUpdateEvent
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        
        configureOutput(output)
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension MyPoseSavedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bookmarkCollectionView {
            return bookmarkContentSizes.value[indexPath.item]
        }
        return CGSize(width: 60, height: 30)
    }
}


extension MyPoseSavedViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return bookmarkContentSizes.value[indexPath.item].height
    }
}

private extension MyPoseSavedViewController {
    func configureOutput(_ output: MyPoseSavedViewModel.Output?) {
        /// 무한스크롤 로직
        /// Reentry anomaly 에러 해결 - 구독중에 복잡한 값 방출
        bookmarkCollectionView.rx.contentOffset
            .asDriver()
            .drive(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                guard let output = output else { return }
                if contentOffset.y > 300
                    && contentOffset.y + 300 > self.bookmarkCollectionView.contentSize.height - self.bookmarkCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                    return
                }
                
                if contentOffset.y > self.bookmarkCollectionView.contentSize.height - self.bookmarkCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        output?.bookmarkContents
            .asDriver()
            .drive(bookmarkCollectionView.rx.items(cellIdentifier: BookmarkFeedCell.identifier, cellType: BookmarkFeedCell.self)) { [weak self] _, viewModel, cell in
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
        
        output?.bookmarkContentSizes
            .subscribe(onNext: { [weak self] in
                self?.bookmarkContentSizes.accept($0)
            })
            .disposed(by: disposeBag)
        
        output?.isLoading
            .map { !$0 }
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
