//
//  PoseUploadImageSourceViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift

final class PoseUploadImageSourceViewModel {
    weak var coordinator: PoseUploadCoordinator?
    private let poseUploadUseCase: PoseUploadUseCase
    
    init(coordinator: PoseUploadCoordinator?, poseUploadUseCase: PoseUploadUseCase) {
        self.coordinator = coordinator
        self.poseUploadUseCase = poseUploadUseCase
    }
    
    struct Input {
        let sourceURL: Observable<String?>
        let submitButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.sourceURL
            .subscribe(onNext: { [weak self] in
                guard let string = $0 else { return }
                self?.coordinator?.sourceURL.accept(string)
            })
            .disposed(by: disposeBag)
        
        input.submitButtonTapEvent
            .flatMapLatest { [weak self] _ -> Observable<(UIImage?, String, String, String, String)> in
                guard let coordinator = self?.coordinator else { return .empty() }
                return coordinator.observeSavePose(disposeBag: disposeBag)
            }
            .subscribe(onNext: { [weak self] (image, headcount, framecount, tags, sourceURL) in
                self?.coordinator?.presentSavePoseCompletedView(image: image, pose: .init(createdAt: nil, frameCount: 4, imageKey: "", peopleCount: 4, poseId: 551, source: "@gangggjuninggg", sourceUrl: sourceURL, tagAttributes: "친구,가족,자연스러움", updatedAt: nil, bookmarkCheck: nil, poseUploadUser: .init(uid: 0, nickname: "", email: "", loginType: "", iosId: nil)))
//                self?.poseUploadUseCase
//                    .savePose(
//                        image: image,
//                        frameCount: framecount,
//                        peopleCount: headcount,
//                        source: "",
//                        sourceUrl: sourceURL,
//                        tag: tags
//                    )
            })
            .disposed(by: disposeBag)
        
        
        
        return output
    }
}

