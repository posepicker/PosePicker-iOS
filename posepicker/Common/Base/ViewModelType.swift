//
//  ViewModelType.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/19.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
