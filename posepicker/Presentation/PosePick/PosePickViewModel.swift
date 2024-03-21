//
//  PosePickViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class PosePickViewModel: ViewModelType {
    
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    
    struct Input {
        let posePickButtonTapped: ControlEvent<Void>
        let isImageLoading: Observable<Bool>
        let isAnimating: Observable<Bool>
        let refetchTrigger: Observable<Void>
        let selectedIndex: BehaviorRelay<Int>
    }
    
    struct Output {
        let animate: Driver<Void>
        let imageUrl: Driver<String>
        let isLoading: Observable<Bool>
        let isPosePickerImageHidden: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let imageUrl = BehaviorRelay<String>(value: "")
        let animate = BehaviorRelay<Void>(value: ())
        let isLoading = BehaviorRelay<Bool>(value: false)
        let isPosePickerImageHidden = BehaviorRelay<Bool>(value: false)
        
        /// 포즈픽 데이터 요청
        input.posePickButtonTapped
            .flatMapLatest { [unowned self] _ -> Observable<Pose> in
                self.apiSession.requestSingle(.retrievePosePick(peopleCount: input.selectedIndex.value + 1)).asObservable()
            }
            .subscribe(onNext: {
                imageUrl.accept($0.poseInfo.imageKey)
            })
            .disposed(by: disposeBag)
        
        /// 이미지 로딩중에 애니메이션 트리거
        input.isImageLoading
            .subscribe(onNext: {
                if $0 {
                    animate.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        /// 탭 이후 애니메이션 트리거
        input.posePickButtonTapped
            .subscribe(onNext: {
                animate.accept(())
                isPosePickerImageHidden.accept(true) // 썸네일 초기 이미지 숨기기
            })
            .disposed(by: disposeBag)
        
        /// 이미지 로딩이 끝나지 않아 로티 재요청
        input.refetchTrigger
            .subscribe(onNext: {
                animate.accept(())
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.isAnimating, input.isImageLoading)
            .subscribe(onNext: { isAnimating, isImageLoading in
                if isAnimating || isImageLoading {
                    isLoading.accept(true)
                } else {
                    isLoading.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(animate: animate.asDriver(), imageUrl: imageUrl.asDriver(), isLoading: isLoading.asObservable(), isPosePickerImageHidden: isPosePickerImageHidden.asObservable())
    }
}
