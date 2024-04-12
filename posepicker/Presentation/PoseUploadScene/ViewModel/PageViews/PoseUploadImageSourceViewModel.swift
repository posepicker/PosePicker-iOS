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
                self?.poseUploadUseCase.savePose(image: image, frameCount: "1", peopleCount: "4", source: "", sourceUrl: sourceURL, tag: tags)
            })
            .disposed(by: disposeBag)
        
        poseUploadUseCase
            .uploadCompletedEvent
            .subscribe(onNext: { [weak self] in
                print("등록 완료된 포즈",$0)
                self?.coordinator?.presentPoseSaveCompletedToast()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

