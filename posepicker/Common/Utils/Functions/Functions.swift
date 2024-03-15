//
//  Functions.swift
//  posepicker
//
//  Created by 박경준 on 3/15/24.
//

import Foundation

struct Functions {
    static func nicknameFromEmail(_ email: String) -> String {
        var nickname = ""
        if let emailAtIndex = email.firstIndex(of: "@") {
            nickname = String(email[email.startIndex..<emailAtIndex])
        }
        
        return nickname
    }
}
