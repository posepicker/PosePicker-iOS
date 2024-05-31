//
//  DefaultPoseTalkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation
import RxSwift
import RxRelay

// 도메인 유스케이스 입장에서는 네트워크 요청이 어떻게 이루어지는지 모름
// 데이터 타입도 모르는게 좋을 것 같다 -> 레포지토리 쪽에서 데이터 정제 후에 유스케이스에 넘겨주기
final class DefaultPoseTalkUseCase: PoseTalkUseCase {
    private let posetalkRepository: PoseTalkRepository
    private var disposeBag = DisposeBag()
    
    var poseWord = BehaviorRelay<String?>(value: nil)
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    init(posetalkRepository: PoseTalkRepository) {
        self.posetalkRepository = posetalkRepository
    }
    
    func fetchPoseTalk() {
        isLoading.accept(true)
        posetalkRepository.fetchPoseWord()
            .subscribe(onNext: { [weak self] poseTalk in
                self?.poseWord.accept(poseTalk)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
