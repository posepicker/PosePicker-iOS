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
import RxDataSources

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
        cv.backgroundColor = .bgWhite
        cv.showsHorizontalScrollIndicator = false
        cv.register(RegisteredFilterCell.self, forCellWithReuseIdentifier: RegisteredFilterCell.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    lazy var poseFeedCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.pinterestLayout)
        cv.backgroundColor = .bgWhite
        cv.register(PoseFeedPhotoCell.self, forCellWithReuseIdentifier: PoseFeedPhotoCell.identifier)
        cv.register(PoseFeedHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedHeader.identifier)
        cv.register(PoseFeedEmptyView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedEmptyView.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    let refreshControl = UIRefreshControl()
        .then {
            $0.tintColor = .mainViolet
        }
    
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
            $0.layer.zPosition = 999
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    let poseUploadButton = PosePickButton(status: .defaultStatus, isFill: true, position: .center, buttonTitle: "", image: ImageLiteral.imgAdd)
        .then {
            $0.layer.zPosition = 999
            $0.layer.cornerRadius = 26
            $0.clipsToBounds = true
        }
    
    let reportToast = Toast(title: "신고가 완료되었습니다")
        .then {
            $0.layer.zPosition = 999
        }
    
    let loginToast = Toast(title: "로그인 되었습니다!")
        .then {
            $0.layer.zPosition = 999
        }
    
    let poseUploadToast = Toast(title: "포즈 업로드가 완료되었습니다!")
        .then {
            $0.layer.zPosition = 999
        }
    
    // MARK: - Properties
    
    var viewModel: PoseFeedViewModel?
    private let filteredContentSizes = BehaviorRelay<[CGSize]>(value: [])
    private let recommendedContentSizes = BehaviorRelay<[CGSize]>(value: [])
    private let infiniteScrollEvent = PublishSubject<Void>()
    private let bookmarkButtonTapEvent = PublishSubject<Section<PoseFeedPhotoCellViewModel>.Item>()
    let viewDidLoadEvent = PublishSubject<Void>()
    let bookmarkBindingEvent = PublishSubject<Int>()
    let dismissFilterModalEvent = PublishSubject<[RegisteredFilterCellViewModel]>()
    let dismissPoseDetailEvent = PublishSubject<RegisteredFilterCellViewModel>()
    let poseUploadCompleteEvent = PublishSubject<Void>()
    let reportCompletedTrigger = PublishSubject<Void>()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    
    override func render() {
        view.addSubViews([filterButton, filterDivider, filterCollectionView, poseFeedCollectionView, supplementLabel, loadingIndicator, poseUploadButton, reportToast, loginToast, poseUploadToast])
        
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
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
        
        poseUploadButton.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        reportToast.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(46)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        
        loginToast.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(46)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        
        poseUploadToast.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(46)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
        
        // 컬렉션뷰
        self.poseFeedCollectionView.refreshControl = refreshControl
        
        poseUploadButton.makeShadow(alpha: 0.5, x: -4, y: -4, blur: 6.8, spread: 0)
        
        // 컬렉션뷰 덮기
        guard let secureView = SecureField().secureContainer else { return }
        
        view.addSubview(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubViews([poseFeedCollectionView, poseUploadButton])
        poseFeedCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
        let input = PoseFeedViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            infiniteScrollEvent: infiniteScrollEvent,
            filterButtonTapEvent: filterButton.rx.tap.asObservable(),
            dismissFilterModalEvent: dismissFilterModalEvent,
            filterTagTapEvent: filterCollectionView.rx.modelSelected(RegisteredFilterCellViewModel.self).asObservable(),
            posefeedPhotoCellTapEvent: poseFeedCollectionView.rx.modelSelected(PoseFeedPhotoCellViewModel.self).asObservable(),
            dismissPoseDetailEvent: dismissPoseDetailEvent,
            bookmarkBindingEvent: bookmarkBindingEvent,
            poseUploadButtonTapEvent: poseUploadButton.rx.tap.asObservable(),
            refreshEvent: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            bookmarkButtonTapEvent: bookmarkButtonTapEvent
        )
        
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        
        configureViewModelOutput(output)
    }
    
    // MARK: - Objc Functions
}

extension PoseFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 30)
    }
}

extension PoseFeedViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return filteredContentSizes.value[indexPath.item].height
        } else {
            return recommendedContentSizes.value[indexPath.item].height
        }
    }
}

private extension PoseFeedViewController {
    func configureViewModelOutput(_ output: PoseFeedViewModel.Output?) {
        guard let output = output else { return }
        
        /// 무한스크롤 로직
        /// Reentry anomaly 에러 해결 - 구독중에 복잡한 값 방출
        poseFeedCollectionView.rx.contentOffset
            .asDriver()
            .drive(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                if contentOffset.y > 300
                    && contentOffset.y + 300 > self.poseFeedCollectionView.contentSize.height - self.poseFeedCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                    return
                }
                
                if contentOffset.y > self.poseFeedCollectionView.contentSize.height - self.poseFeedCollectionView.bounds.size.height
                    && !output.isLoading.value
                    && !output.isLastPage.value {
                    self.infiniteScrollEvent.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        output.contents
            .bind(to: poseFeedCollectionView.rx.items(dataSource: self.configureDataSource()))
            .disposed(by: disposeBag)
        
        // 컨텐츠 세팅 후 컬렉션뷰 스크롤 초기 위치로 이동
        output.registeredTagItems
            .map { $0.count > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.poseFeedCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                guard let flowLayout = self?.poseFeedCollectionView.collectionViewLayout as? PinterestLayout else { return }
                flowLayout.isLoading.accept($0)
                self?.loadingIndicator.isHidden = !$0
            })
            .disposed(by: disposeBag)
        
        output.filteredSectionContentSizes
            .bind(to: filteredContentSizes)
            .disposed(by: disposeBag)
        
        output.recommendedSectionContentSizes
            .bind(to: recommendedContentSizes)
            .disposed(by: disposeBag)
        
        output.registeredTagItems
            .asDriver(onErrorJustReturn: [])
            .drive(filterCollectionView.rx.items(
                cellIdentifier: RegisteredFilterCell.identifier,
                cellType: RegisteredFilterCell.self)
            ){ _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        output.refreshEvent
            .subscribe(onNext: { [weak self] in
                self?.viewDidLoadEvent.onNext(())
            })
            .disposed(by: disposeBag)
        
        output.loginCompleted
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.loginToast.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view).offset(-60)
                }
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                    self.loginToast.layer.opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.loginToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(46)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.loginToast.layer.opacity = 0
                    }
                }
            })
            .disposed(by: disposeBag)
        
        poseUploadCompleteEvent
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewDidLoadEvent.onNext(())
                self.poseUploadToast.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view).offset(-60)
                }
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                    self.poseUploadToast.layer.opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.poseUploadToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(46)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.poseUploadToast.layer.opacity = 0
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reportCompletedTrigger.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.reportToast.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view).offset(-60)
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                    self.reportToast.layer.opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.reportToast.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view).offset(46)
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                        self.reportToast.layer.opacity = 0
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        output.refreshEnded
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<Section<PoseFeedPhotoCellViewModel>>(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PoseFeedPhotoCell.identifier, for: indexPath) as? PoseFeedPhotoCell else { return UICollectionViewCell() }
            cell.disposeBag = DisposeBag()
            cell.viewModel = item
            cell.bind()
            
            /// 북마크 버튼 눌렸을때 로그인 여부 체크 -> 로그인 여부를 뭘로 체크할 것인가?
            /// 키체인 토큰 조회해서 존재하면 북마크 API 요청
            cell.bookmarkButton.rx.tap
                .withUnretained(self)
                .subscribe(onNext: { (owner, _) in
                    owner.bookmarkButtonTapEvent.onNext(item)
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedEmptyView.identifier, for: indexPath) as! PoseFeedEmptyView
                return header
            } else if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PoseFeedHeader.identifier, for: indexPath) as! PoseFeedHeader
                let title = dataSource.sectionModels[indexPath.section].header
                header.configureHeader(with: title)
                return header
            } else { return UICollectionReusableView() }
        })
    }
}
