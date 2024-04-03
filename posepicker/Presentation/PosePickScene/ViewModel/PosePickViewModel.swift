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
        let imageViewTapEvent: Observable<UIImage?>     // 이미지 상세 뷰 띄우기
    }
    
    struct Output {
        let animate = PublishSubject<Void>()
        let poseImage = PublishRelay<UIImage?>()
        let lottieImageHidden = PublishRelay<Bool>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        let selectedPeopleCount = BehaviorRelay<Int>(value: 0)
        
        /// 1. 선택 인원 수 바인딩
        input.selectedPeopleCount
            .bind(to: selectedPeopleCount)
            .disposed(by: disposeBag)
        
        /// 2. 레파지토리로 유스케이스 데이터 저장
        input.posepickButtonEvent
            .subscribe(onNext: { [weak self] in
                output.poseImage.accept(nil)
                self?.posepickUseCase.setImageNil()
                self?.posepickUseCase.fetchPosePick(peopleCount: selectedPeopleCount.value + 1)
                output.animate.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// 3. 유스케이스에 세팅 완료된 데이터 바인딩
        /// 애니메이션 진행중이면 로티와 이미지뷰 히든속성이 교체되면 안됨. 로티 그대로 유지
        Observable.combineLatest(input.isAnimating, self.posepickUseCase.poseImage)
            .subscribe(onNext: { (isAnimating, image) in
                guard let image = image else {
                    if !isAnimating {
                        output.lottieImageHidden.accept(false)
                        output.animate.onNext(())
                    }
                    return
                }
                
                if !isAnimating {
                    output.lottieImageHidden.accept(true)
                    output.poseImage.accept(image)
                }
            })
            .disposed(by: disposeBag)
        
        /// 4. 이미지뷰 탭 이후 상세 이미지 띄우기
        input.imageViewTapEvent
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentDetailImage(retrievedImage: $0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
