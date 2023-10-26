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
    }
    
    struct Output {
        let animate: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        input.posePickButtonTapped
            .flatMapLatest { [unowned self] _ -> Observable<PosePick> in
                self.apiSession.requestSingle(.retrievePosePick(peopleCount: 1)).asObservable()
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        return Output(animate: input.posePickButtonTapped.asDriver())
    }
}
