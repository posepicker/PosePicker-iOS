//
//  BookmarkViewModel.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import Foundation
import RxCocoa
import RxSwift

class BookMarkViewModel {
    
    var apiSession: APISession
    var disposeBag = DisposeBag()
    
    init(apiSession: APISession = APISession()) {
        self.apiSession = apiSession
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
