//
//  DefaultPoseTalkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation
import RxSwift

// 도메인 유스케이스 입장에서는 네트워크 요청이 어떻게 이루어지는지 모름
// 데이터 타입도 모르는게 좋을 것 같다 -> 레포지토리 쪽에서 데이터 정제 후에 유스케이스에 넘겨주기
final class DefaultPoseTalkUseCase: PoseTalkUseCase {
    private let posetalkRepository: DefaultPoseTalkRepository
    private var disposeBag = DisposeBag()
    
    var poseWord = PublishSubject<String>()
    
    init(posetalkRepository: DefaultPoseTalkRepository) {
        self.posetalkRepository = posetalkRepository
    }
    
    func fetchPoseTalk() {
        posetalkRepository.fetchPoseWord()
            .subscribe(onNext: { [weak self] poseTalk in
                self?.poseWord.onNext(poseTalk)
            })
            .disposed(by: disposeBag)
    }
}
