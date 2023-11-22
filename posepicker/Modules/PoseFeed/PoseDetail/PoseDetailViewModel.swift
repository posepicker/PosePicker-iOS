//
//  PoseDetailViewModel.swift
//  posepicker
//
//  Created by Jun on 2023/11/15.
//

import UIKit

import RxCocoa
import RxSwift
import Kingfisher
import KakaoSDKShare
import RxKakaoSDKShare
import KakaoSDKTemplate
import RxKakaoSDKCommon
import KakaoSDKCommon

class PoseDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var poseDetailData: PosePick
    
    init(poseDetailData: PosePick) {
        self.poseDetailData = poseDetailData
    }
    
    struct Input {
        let imageSourceButtonTapped: ControlEvent<Void>
        let linkShareButtonTapped: ControlEvent<Void>
        let kakaoShareButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let imageSourceLink: Observable<URL?>
        let image: Observable<UIImage?>
        let popupPresent: Driver<Void>
        let tagItems: Driver<[PoseDetailTagCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let imageSource = BehaviorRelay<URL?>(value: nil)
        let cacheImage = BehaviorRelay<UIImage?>(value: nil)
        let popupPresent = PublishSubject<Void>()
        let tagItems = BehaviorRelay<[PoseDetailTagCellViewModel]>(value: [])
        
        /// 1. 이미지 출처 - URL 전달
        input.imageSourceButtonTapped
            .subscribe(onNext: { [unowned self] in
                let url = URL(string: "https://" + self.poseDetailData.poseInfo.sourceUrl)
                imageSource.accept(url)
            })
            .disposed(by: disposeBag)
        
        /// 2. 이미지 캐시처리 (캐시에서 불러오기)
        ImageCache.default.retrieveImage(forKey: poseDetailData.poseInfo.imageKey, options: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if let image = value.image {
                    let newSizeImage = self.newSizeImageWidthDownloadedResource(image: image)
                    cacheImage.accept(newSizeImage)
                } else {
                    guard let url = URL(string: self.poseDetailData.poseInfo.imageKey) else { return }
                    KingfisherManager.shared.retrieveImage(with: url) { downloadResult in
                        switch downloadResult {
                        case .success(let downloadImage):
                            let newSizeImage = self.newSizeImageWidthDownloadedResource(image: downloadImage.image)
                            cacheImage.accept(newSizeImage)
                        case .failure:
                            return
                        }
                    }
                }
            case .failure:
                cacheImage.accept(nil)
            }
        }
        
        /// 3. 링크 복사 버튼 탭
        input.linkShareButtonTapped
            .subscribe(onNext: { [unowned self] in
                UIPasteboard.general.string = "https://www.posepicker.site/detail/\(self.poseDetailData.poseInfo.poseId)"
                popupPresent.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 4. 태그 정보
        let tags = getTagArrayFromData(peopleCount: poseDetailData.poseInfo.peopleCount, frameCount: poseDetailData.poseInfo.frameCount, tagString: poseDetailData.poseInfo.tagAttributes)
        tagItems.accept(tags.map { PoseDetailTagCellViewModel(title: $0) })
        
        /// 5. 카카오 공유하기 버튼
        input.kakaoShareButtonTapped
            .subscribe(onNext: { [unowned self] in
                let template = self.getFeedTemplateObject()
                    
                // 메시지 템플릿 encode
                if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
                    // 생성한 메시지 템플릿 객체를 jsonObject로 변환
                    if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                        // 카카오톡 앱이 있는지 체크합니다.
                        if ShareApi.isKakaoTalkSharingAvailable() {
                            ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
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
        
        return Output(imageSourceLink: imageSource.asObservable(), image: cacheImage.asObservable(), popupPresent: popupPresent.asDriver(onErrorJustReturn: ()), tagItems: tagItems.asDriver())
    }
    
    /// 디자인 수치 기준으로 이미지 리사이징
    func newSizeImageWidthDownloadedResource(image: UIImage) -> UIImage {
        let targetWidth = UIScreen.main.bounds.width
        let newSizeImage = image.resize(newWidth: targetWidth)
        return newSizeImage
    }
    
    /// 주입된 포즈 디테일 데이터를 String 배열값으로 정리
    func getTagArrayFromData(peopleCount: Int, frameCount: Int, tagString: String?) -> [String] {
        var tags: [String] = [peopleCount >= 5 ? "5인+" : "\(peopleCount)인", frameCount >= 8 ? "8컷+" : "\(frameCount)컷"]
        
        if let tagString = tagString {
            tags += tagString.split(separator: ",").map { String($0) }
        }
        
        return tags
    }
    
    func getFeedTemplateObject() -> FeedTemplate {
        let link = Link(webUrl: URL(string: "https://www.posepicker.site/detail/\(self.poseDetailData.poseInfo.poseId)"),
                            mobileWebUrl: URL(string: "https://www.posepicker.site/detail/\(self.poseDetailData.poseInfo.poseId)"))

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
