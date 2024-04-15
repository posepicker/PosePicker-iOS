//
//  MockCommonUseCase.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 4/3/24.
//

import Foundation
@testable import posepicker

final class MockCommonUseCase: CommonUseCase {
    func loginWithKakao() {
        print("카카오 로그인 완료")
    }
    
    func loginWithApple(idToken: String) {
        print("애플 로그인 완료")
    }
}
