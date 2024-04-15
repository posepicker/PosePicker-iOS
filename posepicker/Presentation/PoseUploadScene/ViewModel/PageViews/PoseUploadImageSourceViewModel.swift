//
//  PoseUploadImageSourceViewModel.swift
//  posepicker
//
//  Created by 박경준 on 4/11/24.
//

import UIKit
import RxSwift
import RxRelay

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
        let isLoading = BehaviorRelay<Bool>(value: false)
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
                output.isLoading.accept(true)
                var headcount = headcount
                var framecount = framecount
                _ = headcount.removeLast()
                _ = framecount.removeLast()
                self?.poseUploadUseCase.savePose(image: image, frameCount: framecount, peopleCount: headcount, source: "", sourceUrl: sourceURL, tag: tags)
            }, onError: { _ in
                output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        poseUploadUseCase
            .uploadCompletedEvent
            .subscribe(onNext: { [weak self] in
                print("등록 완료된 포즈",$0)
                output.isLoading.accept(false)
                self?.coordinator?.presentPoseSaveCompletedToast()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

