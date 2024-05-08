//
//  MyPoseViewModel.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class MyPoseViewModel {
    weak var coordinator: MyPoseCoordinator?
    private let myPoseUseCase: MyPoseUseCase
    
    init(coordinator: MyPoseCoordinator?, myPoseUseCase: MyPoseUseCase) {
        self.coordinator = coordinator
        self.myPoseUseCase = myPoseUseCase
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        let uploadedCount = BehaviorRelay<String>(value: "등록 0")
        let savedCount = BehaviorRelay<String>(value: "저장 0")
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input
            .viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.myPoseUseCase.fetchPoseCount()
            })
            .disposed(by: disposeBag)
        
        myPoseUseCase
            .uploadedPoseCount
            .subscribe(onNext: {
                output.uploadedCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        myPoseUseCase
            .savedPoseCount
            .subscribe(onNext: {
                output.savedCount.accept($0)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
