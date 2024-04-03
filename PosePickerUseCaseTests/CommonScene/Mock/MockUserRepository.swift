//
//  MockCommonRepository.swift
//  PosePickerUseCaseTests
//
//  Created by 박경준 on 4/2/24.
//

import Foundation
import RxSwift

@testable import posepicker

final class MockUserRepository: UserRepository {
    func loginWithKakao() -> Observable<PosePickerUser> {
        return Observable<PosePickerUser>.empty()
    }
    
    func loginWithApple(idToken: String) -> Observable<PosePickerUser> {
        return Observable<PosePickerUser>.empty()
    }
    
    func reissueToken(refreshToken: String) -> Observable<Token> {
        return Observable<Token>.empty()
    }
    
    func logout(accessToken: String, refreshToken: String) -> Observable<MeaninglessResponse> {
        return Observable<MeaninglessResponse>.empty()
    }
    
    func deleteUserInfo(accessToken: String, refreshToken: String, withdrawalReason: String) -> Observable<MeaninglessResponse> {
        return Observable<MeaninglessResponse>.empty()
    }
}
