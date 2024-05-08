//
//  DefaultMyPoseUse.swift
//  posepicker
//
//  Created by 박경준 on 5/8/24.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultMyPoseUseCase: MyPoseUseCase {
    private var disposeBag = DisposeBag()
    private let myPoseRepository: MyPoseRepository
    
    init(myPoseRepository: MyPoseRepository) {
        self.myPoseRepository = myPoseRepository
    }
    
    var uploadedPoseCount = PublishSubject<String>()
    var savedPoseCount = PublishSubject<String>()
    
    func fetchPoseCount() {
        myPoseRepository
            .fetchPoseCount()
            .subscribe(onNext: { [weak self] in
                self?.uploadedPoseCount.onNext("등록 \($0.uploadCount)")
                self?.savedPoseCount.onNext("저장 \($0.bookmarkCount)")
            })
            .disposed(by: disposeBag)
    }
}
