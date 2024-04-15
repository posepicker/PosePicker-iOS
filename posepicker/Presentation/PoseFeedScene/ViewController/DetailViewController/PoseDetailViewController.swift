//
//  PoseDetailViewController.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit
import RxSwift
import RxCocoa

class PoseDetailViewController: BaseViewController {

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
    
    let imageSourceButton = UIButton(type: .system)
        .then {
            var configuration = UIButton.Configuration.filled()
            configuration.titlePadding = 5
            configuration.baseBackgroundColor = .bgDivider
            configuration.attributedTitle = AttributedString("", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.pretendard(.medium, ofSize: 14)]))
            $0.configuration = configuration
            $0.titleLabel?.font = .pretendard(.medium, ofSize: 14)
            $0.setTitleColor(.textBrand, for: .normal)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
        }
    
    lazy var navigationBar = UINavigationBar()
        .then {
            let closeButton = UIBarButtonItem(image: ImageLiteral.imgClose24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault), style: .plain, target: self, action: #selector(closeButtonTapped))

            let navigationItem = UINavigationItem(title: "")
            navigationItem.leftBarButtonItems = [closeButton]
            navigationItem.rightBarButtonItems = [showMoreButton, bookmarkButton]
            $0.items = [navigationItem]
        }
    
    let imageButton = UIButton()
        .then {
            $0.adjustsImageWhenHighlighted = false
            $0.contentMode = .scaleAspectFill
        }
    
    lazy var tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .bgWhite
        cv.register(PoseDetailTagCell.self, forCellWithReuseIdentifier: PoseDetailTagCell.identifier)
        cv.rx.setDelegate(self).disposed(by: disposeBag)
        return cv
    }()
    
    let shareButtonGroup = UIView()
        .then {
            $0.backgroundColor = .bgWhite
        }
    
    let linkShareButton = PosePickButton(status: .defaultStatus, isFill: false, position: .none, buttonTitle: "링크 공유", image: nil)
    
    let kakaoShareButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "카카오 공유", image: nil)
        .then {
            $0.setTitle("카카오 공유", for: .normal)
            $0.setTitle("", for: .disabled)
        }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
        .then {
            $0.isHidden = true
            $0.startAnimating()
            $0.color = .iconWhite
        }
    
    lazy var bookmarkButton = UIBarButtonItem(image: ImageLiteral.imgBookmarkOff24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault), style: .plain, target: self, action: #selector(bookmarkButtonTapped))
    
    lazy var showMoreButton = UIBarButtonItem(image: ImageLiteral.imgMore.withTintColor(.iconDefault, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(showMoreButtonTapped))
    
    // MARK: - Properties
    
    var viewModel: PoseDetailViewModel?
    
    let appleIdentityTokenTrigger = PublishSubject<String>()
    let kakaoEmailTrigger = PublishSubject<String>()
    let kakaoIdTrigger = PublishSubject<Int64>()
    
    private let viewDidLoadEvent = PublishSubject<Void>()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadEvent.onNext(())
    }
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([navigationBar, scrollView, shareButtonGroup, loadingIndicator])
        
        scrollView.subviews.first!.addSubViews([imageSourceButton, imageButton, tagCollectionView])
        shareButtonGroup.addSubViews([linkShareButton, kakaoShareButton])
        
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.top)
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
            make.bottom.equalTo(shareButtonGroup.snp.top)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }
        
        imageSourceButton.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).offset(20)
            make.top.equalTo(scrollView).offset(14)
        }
        
        imageButton.snp.makeConstraints { make in
            make.top.equalTo(imageSourceButton.snp.bottom).offset(14)
            make.leading.trailing.equalTo(scrollView)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(72)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        
        shareButtonGroup.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(100)
        }
        
        linkShareButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo((UIScreen.main.bounds.width - 48) * 0.3) // 좌우 패딩 40 + 버튼 간격 8
            make.leading.equalTo(shareButtonGroup).offset(20)
            make.centerY.equalTo(shareButtonGroup)
        }
        
        kakaoShareButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo((UIScreen.main.bounds.width - 48) * 0.7)
            make.trailing.equalTo(shareButtonGroup).offset(-20)
            make.centerY.equalTo(shareButtonGroup)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(kakaoShareButton)
        }
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
        
        navigationBar.standardAppearance.backgroundColor = .bgWhite
        navigationBar.standardAppearance.shadowColor = nil
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        scrollView.subviews.first!.addSubView(secureView)
        secureView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(imageSourceButton.snp.bottom)
        }
        
        secureView.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
        let input = PoseDetailViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent,
            kakaoShareButtonTapEvent: kakaoShareButton.rx.tap.asObservable(),
            linkShareButtonTapEvent: linkShareButton.rx.tap.asObservable(),
            imageSourceButtonTapEvent: imageSourceButton.rx.tap.asObservable(),
            poseTagTapEvent: tagCollectionView.rx.modelSelected(PoseDetailTagCellViewModel.self).asObservable(),
            showMoreButtonTapEvent: showMoreButton.rx.tap.asObservable(),
            bookmarkButtonTapEvent: bookmarkButton.rx.tap.asObservable()
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        
        configureOutput(output)
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    /// 북마크 API 연동
    @objc func bookmarkButtonTapped() { }
    
    @objc func showMoreButtonTapped() { }
}

private extension PoseDetailViewController {
    func configureOutput(_ output: PoseDetailViewModel.Output?) {
        output?.image
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                self?.imageButton.setImage($0, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output?.source
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in
                if !$0.isEmpty {
                    self?.imageSourceButton.isHidden = false
                    self?.imageSourceButton.configuration?.attributedTitle = AttributedString($0 + "↗", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.pretendard(.medium, ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.textBrand]))
                } else {
                    self?.imageSourceButton.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        output?.tagItems
            .asDriver()
            .drive(tagCollectionView.rx.items(cellIdentifier: PoseDetailTagCell.identifier, cellType: PoseDetailTagCell.self)) { _, viewModel, cell in
                cell.disposeBag = DisposeBag()
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        output?.isLoading
            .asDriver()
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.kakaoShareButton.isEnabled = false
                    self?.loadingIndicator.isHidden = false
                } else {
                    self?.kakaoShareButton.isEnabled = true
                    self?.loadingIndicator.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        output?.bookmarkChecked
            .asDriver()
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.bookmarkButton.image = ImageLiteral.imgBookmarkFill24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault)
                } else {
                    self?.bookmarkButton.image = ImageLiteral.imgBookmarkOff24.withRenderingMode(.alwaysOriginal).withTintColor(.iconDefault)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension PoseDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 32)
    }
}
