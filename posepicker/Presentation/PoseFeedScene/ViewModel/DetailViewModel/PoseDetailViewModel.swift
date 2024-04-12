//
//  PoseDetailViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/5/24.
//

import UIKit
import RxSwift
import RxRelay
import KakaoSDKShare
import RxKakaoSDKShare
import KakaoSDKTemplate
import RxKakaoSDKCommon
import KakaoSDKCommon

final class PoseDetailViewModel {
    weak var coordinator: PoseFeedCoordinator?
    private var poseDetailUseCase: PoseDetailUseCase
    private let bindViewModel: PoseFeedPhotoCellViewModel
    
    init(coordinator: PoseFeedCoordinator?, poseDetailUseCase: PoseDetailUseCase, bindViewModel: PoseFeedPhotoCellViewModel) {
        self.coordinator = coordinator
        self.poseDetailUseCase = poseDetailUseCase
        self.bindViewModel = bindViewModel
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let kakaoShareButtonTapEvent: Observable<Void>
        let linkShareButtonTapEvent: Observable<Void>
        let imageSourceButtonTapEvent: Observable<Void>
        let poseTagTapEvent: Observable<PoseDetailTagCellViewModel>
        let showMoreButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
        let tagItems = BehaviorRelay<[PoseDetailTagCellViewModel]>(value: [])
        let source = PublishRelay<String>()
        let isLoading = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let sourceURL = BehaviorRelay<String>(value: "")
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.poseDetailUseCase.getSourceURLFromPoseInfo()
                self?.poseDetailUseCase.getTagsFromPoseInfo()
                self?.poseDetailUseCase.getSourceFromPoseInfo()
            })
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .tagItems
            .map { tags in
                tags.map { PoseDetailTagCellViewModel(title: $0)}
            }
            .subscribe(onNext: {
                output.tagItems.accept($0)
            })
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .source
            .subscribe(onNext: {
                output.source.accept($0)
            })
            .disposed(by: disposeBag)
        
        /// 5. 카카오 공유하기 버튼
        input.kakaoShareButtonTapEvent
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                let template = owner.getFeedTemplateObject()
                output.isLoading.accept(true)
                // 메시지 템플릿 encode
                if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
                    // 생성한 메시지 템플릿 객체를 jsonObject로 변환
                    if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                        // 카카오톡 앱이 있는지 체크합니다.
                        if ShareApi.isKakaoTalkSharingAvailable() {
                            ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
                                output.isLoading.accept(false)
                                if let error = error {
                                    print("error : \(error)")
                                }
                                else {
                                    print("defaultLink(templateObject:templateJsonObject) success.")
                                    guard let linkResult = linkResult else { return }
                                    UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                                }
                            }
                        } else {
                            // 없을 경우 카카오톡 앱스토어로 이동합니다. (이거 하려면 URL Scheme에 itms-apps 추가 해야함)
                            output.isLoading.accept(false)
                            let url = "itms-apps://itunes.apple.com/app/362057947"
                            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.linkShareButtonTapEvent
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                UIPasteboard.general.string = "https://www.posepicker.site/detail/\(owner.bindViewModel.poseId.value)"
                owner.coordinator?.presentClipboardCompleted(poseId: owner.bindViewModel.poseId.value)
            })
            .disposed(by: disposeBag)
        
        input.imageSourceButtonTapEvent
            .withUnretained(self)
            .flatMapLatest { (owner, _) in
                return sourceURL
            }
            .map {
                return URL(string: "https://" + $0)
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.moveToExternalApp(url: $0)
            })
            .disposed(by: disposeBag)
        
        self.poseDetailUseCase
            .sourceUrl
            .subscribe(onNext: {
                sourceURL.accept($0)
            })
            .disposed(by: disposeBag)
        
        input.poseTagTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.dismissPoseDetail(tag: $0.title.value)
            })
            .disposed(by: disposeBag)
        
        input.showMoreButtonTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.coordinator?.presentShowMoreModal(poseId: self.bindViewModel.poseId.value)
            })
            .disposed(by: disposeBag)
        
        output.image.accept(
            bindViewModel.image.value?.resize(newWidth: UIScreen.main.bounds.width)
        )
        
        return output
    }
    
    private func getFeedTemplateObject() -> FeedTemplate {
        let link = Link(webUrl: URL(string: "https://www.posepicker.site/detail/\(self.bindViewModel.poseId.value)"),
                        mobileWebUrl: URL(string: "https://www.posepicker.site/detail/\(self.bindViewModel.poseId.value)"))

        // 앱 링크입니다. 파라미터를 함께 전달하여 앱으로 들어왔을 때 특정 페이지로 이동할 수 있는 역할을 합니다.
//        let appLink = Link(androidExecutionParams: ["key1": "value1", "key2": "value2"],
//                           iosExecutionParams: ["key1": "value1", "key2": "value2"])
        
        // 버튼들 입니다.
        let webButton = Button(title: "포즈가 고민될 땐? 포즈피커!", link: link)
//        let appButton = Button(title: "앱으로 보기", link: appLink) // MARK: - 포즈피커 앱으로 연결
        
        // 메인이 되는 사진, 이미지 URL, 클릭 시 이동하는 링크를 설정합니다.
        let content = Content(title: "PosePicker | 포즈피커",
                              imageUrl: URL(string: "https://www.posepicker.site/meta/og_kakao.png")!,
                              link: link)
        return FeedTemplate(content: content, buttons: [webButton])
    }
}
