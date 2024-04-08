//
//  PoseDetailViewController.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit
import RxSwift

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
    
    let tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .bgWhite
        cv.register(PoseDetailTagCell.self, forCellWithReuseIdentifier: PoseDetailTagCell.identifier)
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
        
//        let sourceText = viewModel.poseDetailData.poseInfo.source
//        if !sourceText.isEmpty {
//            imageSourceButton.configuration?.attributedTitle = AttributedString(sourceText + "↗", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.pretendard(.medium, ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.textBrand]))
//        } else {
//            imageSourceButton.isHidden = true
//        }
        
        // 캡처시 이미지 덮기
        guard let secureView = SecureField().secureContainer else { return }

        scrollView.subviews.first!.addSubView(secureView)
        secureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        secureView.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(secureView)
        }
    }
    
    override func bindViewModel() {
        let input = PoseDetailViewModel.Input(
            viewDidLoadEvent: viewDidLoadEvent
        )
        let output = viewModel?.transform(input: input, disposeBag: disposeBag)
        
        configureOutput(output)
//        let input = PoseDetailViewModel.Input(imageSourceButtonTapped: imageSourceButton.rx.tap, linkShareButtonTapped: linkShareButton.rx.tap, kakaoShareButtonTapped: kakaoShareButton.rx.tap, bookmarkButtonTapped: bookmarkButton.rx.tap, appleIdentityTokenTrigger: appleIdentityTokenTrigger, kakaoLoginTrigger: Observable.combineLatest(kakaoEmailTrigger, kakaoIdTrigger))
//        
//        let output = viewModel.transform(input: input)
//        
//        output.imageSourceLink
//            .compactMap { $0 }
//            .subscribe(onNext: {
//                UIApplication.shared.open($0)
//            })
//            .disposed(by: disposeBag)
//    
//        output.image.asDriver(onErrorJustReturn: nil)
//            .drive(onNext: { [weak self] in
//                self?.imageButton.setImage($0, for: .normal)
//            })
//            .disposed(by: disposeBag)
//        
//        imageButton.rx.tap.asDriver()
//            .drive(onNext: { [weak self] in
//                guard let retrievedImage = self?.imageButton.imageView?.image else { return }
//                let vc = ImagePopUpViewController(mainImage: retrievedImage)
//                vc.modalTransitionStyle = .crossDissolve
//                vc.modalPresentationStyle = .overFullScreen
//                self?.present(vc, animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        output.popupPresent
//            .drive(onNext: { [unowned self] in
//                let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: false)
//                popupViewController.modalTransitionStyle = .crossDissolve
//                popupViewController.modalPresentationStyle = .overFullScreen
//                let popupView = popupViewController.popUpView as! PopUpView
//                popupView.alertText.accept("링크가 복사되었습니다.")
//                self.present(popupViewController, animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        output.tagItems
//            .drive(tagCollectionView.rx.items(cellIdentifier: PoseDetailTagCell.identifier, cellType: PoseDetailTagCell.self)) { _, viewModel, cell in
//                cell.disposeBag = DisposeBag()
//                cell.bind(to: viewModel)
//            }
//            .disposed(by: disposeBag)
//        
//        tagCollectionView.rx.modelSelected(PoseDetailTagCellViewModel.self)
//            .flatMapLatest { $0.title }
//            .subscribe(onNext: { [unowned self] in
//                self.coordinator.dismissPoseDetailWithTagSelection(tag: $0)
//                self.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        output.isLoading.asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [unowned self] in
//                if $0 {
//                    self.kakaoShareButton.isEnabled = false
//                    self.loadingIndicator.isHidden = false
//                } else {
//                    self.kakaoShareButton.isEnabled = true
//                    self.loadingIndicator.isHidden = true
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        output.bookmarkCheck
//            .compactMap { $0 }
//            .drive(onNext: { [weak self] in
//                guard let self = self else { return }
//                if $0 {
//                    self.bookmarkButton.image = ImageLiteral.imgBookmarkFill24.withTintColor(.iconDefault, renderingMode: .alwaysOriginal)
//                    self.coordinator.triggerBookmarkFromPoseId(poseId: self.viewModel.poseDetailData.poseInfo.poseId, bookmarkCheck: true)
//                } else {
//                    self.bookmarkButton.image = ImageLiteral.imgBookmarkOff24.withTintColor(.iconDefault, renderingMode: .alwaysOriginal)
//                    self.coordinator.triggerBookmarkFromPoseId(poseId: self.viewModel.poseDetailData.poseInfo.poseId, bookmarkCheck: false)
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        output.loginPopUpPresent.asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] in
//                guard let self = self else { return }
//                
//                let popUpVC = PopUpViewController(isLoginPopUp: true, isChoice: false)
//                popUpVC.modalTransitionStyle = .crossDissolve
//                popUpVC.modalPresentationStyle = .overFullScreen
//                self.present(popUpVC, animated: true)
//                
//                popUpVC.appleIdentityToken
//                    .compactMap { $0 }
//                    .subscribe(onNext: { [unowned self] in
//                        self.appleIdentityTokenTrigger.onNext($0)
//                    })
//                    .disposed(by: self.disposeBag)
//                
//                popUpVC.email
//                    .compactMap { $0 }
//                    .subscribe(onNext: { [unowned self] in
//                        self.kakaoEmailTrigger.onNext($0)
//                    })
//                    .disposed(by: self.disposeBag)
//                
//                popUpVC.kakaoId
//                    .compactMap { $0 }
//                    .subscribe(onNext: { [unowned self] in
//                        self.kakaoIdTrigger.onNext($0)
//                    })
//                    .disposed(by: self.disposeBag)
//            })
//            .disposed(by: disposeBag)
//        
//        output.dismissLoginView
//            .subscribe(onNext: { [unowned self] in
//                guard let popupVC = self.presentedViewController as? PopUpViewController,
//                      let _ = popupVC.popUpView as? LoginPopUpView else { return }
//                self.dismiss(animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        tagCollectionView.updateCollectionViewHeight()
    }
    
    // MARK: - Objc Functions
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    /// 북마크 API 연동
    @objc
    func bookmarkButtonTapped() {
        
    }
    
    @objc
    func showMoreButtonTapped() {
//        let modalVC = PoseDetailMoreViewController(poseId: viewModel.poseDetailData.poseInfo.poseId)
//        if let sheet = modalVC.sheetPresentationController {
//            sheet.detents = [.custom { _ in 180}]
//            sheet.preferredCornerRadius = 20
//        }
//        
//        self.present(modalVC, animated: true)
    }
}

private extension PoseDetailViewController {
    func configureOutput(_ output: PoseDetailViewModel.Output?) {
        output?.image
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                self?.imageButton.setImage($0, for: .normal)
            })
            .disposed(by: disposeBag)
        
        //        let sourceText = viewModel.poseDetailData.poseInfo.source
        //        if !sourceText.isEmpty {
        //            imageSourceButton.configuration?.attributedTitle = AttributedString(sourceText + "↗", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.pretendard(.medium, ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.textBrand]))
        //        } else {
        //            imageSourceButton.isHidden = true
        //        }
        
        output?.url
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in
                if !$0.isEmpty {
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
    }
}
