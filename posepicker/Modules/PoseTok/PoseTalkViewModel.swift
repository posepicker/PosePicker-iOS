//
//  PoseTalkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class PoseTalkViewModel: ViewModelType {
    var apiSession: APIService = APISession()
    var disposeBag = DisposeBag()
    
    struct Input {
        let poseTalkButtonTapped: ControlEvent<Void>
        let isAnimating: Observable<Bool>
    }
    
    struct Output {
        let animate: Driver<Void>
        let poseWord: Observable<String>
        let isLoading: BehaviorRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let poseWord = BehaviorRelay<String>(value: "제시어에 맞춰\n포즈를 취해요!")
        let isLoading = BehaviorRelay<Bool>(value: false)
        
        input.poseTalkButtonTapped
            .flatMapLatest { [unowned self] _ -> Observable<PoseTalk> in
                self.apiSession.requestSingle(.retrievePoseTalk).asObservable()
            }
            .subscribe(onNext: {
                poseWord.accept($0.poseWord.content)
            })
            .disposed(by: disposeBag)
        
        /// 애니메이션 + 네트워크 관련 로직 추가를 고려한 설계
        input.isAnimating
            .subscribe(onNext: {
                isLoading.accept($0)
            })
            .disposed(by: disposeBag)
        
        return Output(animate: input.poseTalkButtonTapped.asDriver(), poseWord: poseWord.asObservable(), isLoading: isLoading)
    }
}
