//
//  PoseDetailViewController.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit

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
    
    let navigationBar = UINavigationBar()
        .then {
            let closeButton = UIBarButtonItem(image: ImageLiteral.imgClose24, style: .plain, target: self, action: #selector(closeButtonTapped))
            let bookmarkButton = UIBarButtonItem(image: ImageLiteral.imgBookmarkOff24, style: .plain, target: self, action: #selector(bookmarkButtonTapped))

              let navigationItem = UINavigationItem(title: "")
              navigationItem.leftBarButtonItem = closeButton
              navigationItem.rightBarButtonItem = bookmarkButton

              $0.items = [navigationItem]
        }
    
    let imageView = UIImageView()
        .then {
            $0.contentMode = .scaleAspectFill
        }
    
    let tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PoseDetailTagCell.self, forCellWithReuseIdentifier: PoseDetailTagCell.identifier)
        return cv
    }()
    
    let shareButtonGroup = UIView()
        .then {
            $0.backgroundColor = .bgWhite
        }
    
    let linkShareButton = PosePickButton(status: .defaultStatus, isFill: false, position: .none, buttonTitle: "링크 공유", image: nil)
    
    let kakaoShareButton = PosePickButton(status: .defaultStatus, isFill: true, position: .none, buttonTitle: "카카오 공유", image: nil)
    
    
    // MARK: - Properties
    
    var viewModel: PoseDetailViewModel
    var coordinator: PoseFeedCoordinator
    
    // MARK: - Initialization
    
    init(viewModel: PoseDetailViewModel, coordinator: PoseFeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func render() {
        self.view.addSubViews([navigationBar, scrollView, shareButtonGroup])
        
        scrollView.subviews.first!.addSubViews([imageSourceButton, imageView, tagCollectionView])
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
        }
        
        imageSourceButton.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).offset(20)
            make.top.equalTo(scrollView).offset(14)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(imageSourceButton.snp.bottom).offset(14)
            make.leading.trailing.equalTo(scrollView)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
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
    }
    
    override func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .bgWhite
        
        navigationBar.standardAppearance.backgroundColor = .bgWhite
        navigationBar.standardAppearance.shadowColor = nil
        
        let sourceText = viewModel.poseDetailData.poseInfo.source
        if !sourceText.isEmpty {
            imageSourceButton.configuration?.attributedTitle = AttributedString(sourceText + "↗", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.pretendard(.medium, ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.textBrand]))
        } else {
            imageSourceButton.isHidden = true
        }
        
    }
    override func bindViewModel() {
        let input = PoseDetailViewModel.Input(imageSourceButtonTapped: imageSourceButton.rx.tap, linkShareButtonTapped: linkShareButton.rx.tap, kakaoShareButtonTapped: kakaoShareButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.imageSourceLink
            .compactMap { $0 }
            .subscribe(onNext: {
                UIApplication.shared.open($0)
            })
            .disposed(by: disposeBag)
        
        output.image.bind(to: imageView.rx.image).disposed(by: disposeBag)
        
        output.popupPresent
            .drive(onNext: { [unowned self] in
                let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: false)
                popupViewController.modalTransitionStyle = .crossDissolve
                popupViewController.modalPresentationStyle = .overFullScreen
                let popupView = popupViewController.popUpView as! PopUpView
                popupView.alertText.accept("링크가 복사되었습니다.")
                self.present(popupViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.tagItems
            .drive(tagCollectionView.rx.items(cellIdentifier: PoseDetailTagCell.identifier, cellType: PoseDetailTagCell.self)) { _, viewModel, cell in
                cell.bind(to: viewModel)
            }
            .disposed(by: disposeBag)
        
        tagCollectionView.rx.modelSelected(PoseDetailTagCellViewModel.self)
            .flatMapLatest { $0.title }
            .subscribe(onNext: { [unowned self] in
                self.coordinator.dismissPoseDetailWithTagSelection(tag: $0)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        tagCollectionView.updateCollectionViewHeight()
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
}
