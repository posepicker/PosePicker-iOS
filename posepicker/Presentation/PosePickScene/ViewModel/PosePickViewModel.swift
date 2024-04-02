//
//  PosePickViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit
import RxCocoa
import RxSwift

final class PosePickViewModel {
    weak var coordinator: PosePickCoordinator?
    private let posepickUseCase: PosePickUseCase
    
    init(coordinator: PosePickCoordinator?, posepickUseCase: PosePickUseCase) {
        self.coordinator = coordinator
        self.posepickUseCase = posepickUseCase
    }
    
    struct Input {
        let selectedPeopleCount: Observable<Int>        // 선택 인원수
        let posepickButtonEvent: Observable<Void>       // 포즈픽 API 요청 버튼
        let isAnimating: Observable<Bool>               // 로딩 상태값
    }
    
    struct Output {
        let animate = PublishSubject<Void>()
        let poseImage = PublishRelay<UIImage>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        /// 2. 레파지토리로 유스케이스 데이터 저장
        Observable.combineLatest(input.selectedPeopleCount, input.posepickButtonEvent)
            .subscribe(onNext: { [weak self] (peopleCount, _) in
                self?.posepickUseCase.fetchPosePick(peopleCount: peopleCount)
                output.animate.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 3. 유스케이스에 세팅 완료된 데이터 바인딩
        /// 애니메이션 진행중이면 로티와 이미지뷰 히든속성이 교체되면 안됨. 로티 그대로 유지
        Observable.combineLatest(input.isAnimating, self.posepickUseCase.poseImage)
            .subscribe(onNext: { (isAnimating, image) in
                print("애니메이팅",isAnimating)
                if !isAnimating {
                    output.poseImage.accept(image)
                }
            })
            .disposed(by: disposeBag)
        
//        self.posepickUseCase.poseImage
//            .subscribe(onNext: {
//                output.poseImage.accept($0)
//                output.isLottieHidden.accept(true)
//                output.isImageHidden.accept(false)
//            })
//            .disposed(by: disposeBag)
        
        return output
    }
}
