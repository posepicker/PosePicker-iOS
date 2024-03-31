//
//  Result+.swift
//  posepicker
//
//  Created by 박경준 on 3/31/24.
//

import Foundation

extension Result {
    var isSuccess: Bool { if case .success = self { return true } else { return false } }

    var isError: Bool {  return !isSuccess  }
}

