//
//  DefaultPoseTalkUseCase.swift
//  posepicker
//
//  Created by 박경준 on 3/21/24.
//

import Foundation
import RxSwift

final class DefaultPoseTalkUseCase: PoseTalkUseCase {
    private let posetalkRepository: DefaultPoseTalkRepository
    private let disposeBag = DisposeBag()
    
    var poseWord = PublishSubject<String>()
    
    init(posetalkRepository: DefaultPoseTalkRepository) {
        self.posetalkRepository = posetalkRepository
    }
    
    func fetchPoseTalk() {
        posetalkRepository.fetchPoseWord()
            .subscribe(onNext: { [weak self] poseTalk in
                self?.poseWord.onNext(poseTalk.poseWord.content)
            })
            .disposed(by: disposeBag)
    }
}
