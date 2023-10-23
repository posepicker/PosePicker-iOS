//
//  BindableViewModel.swift
//  posepicker
//
//  Created by Jun on 2023/10/23.
//

import Foundation
import RxSwift

protocol BindableViewModel {
    var apiSession: APIService { get }
    
    var bag: DisposeBag { get }
}
