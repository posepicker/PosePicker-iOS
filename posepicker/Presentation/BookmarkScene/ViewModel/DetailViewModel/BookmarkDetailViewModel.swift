//
//  BookmarkDetailViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/9/24.
//

import UIKit
import RxSwift
import RxRelay
import KakaoSDKShare
import RxKakaoSDKShare
import KakaoSDKTemplate
import RxKakaoSDKCommon
import KakaoSDKCommon

final class BookmarkDetailViewModel {
    weak var coordinator: BookmarkCoordinator?
    private let poseDetailUseCase: PoseDetailUseCase
    private let bindViewModel: BookmarkFeedCellViewModel
    
    init(coordinator: BookmarkCoordinator, poseDetailUseCase: PoseDetailUseCase, bindViewModel: BookmarkFeedCellViewModel) {
        self.coordinator = coordinator
        self.poseDetailUseCase = poseDetailUseCase
        self.bindViewModel = bindViewModel
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        let image = BehaviorRelay<UIImage?>(value: nil)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.poseDetailUseCase.getSourceURLFromPoseInfo()
                self?.poseDetailUseCase.getTagsFromPoseInfo()
                self?.poseDetailUseCase.getSourceFromPoseInfo()
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
