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
    
    func logout() -> Observable<posepicker.LogoutResponse> {
        return .just(
            .init(
                entity: "entity",
                message: "message",
                status: 200
            )
        )
    }
    
    func loginWithKakao() -> Observable<PosePickerUser> {
        return Observable<PosePickerUser>.just(
            .init(
                email: "rudwns3927@gmail.com",
                id: 1,
                nickname: "parkjju",
                token: .init(
                    accessToken: "eyj..",
                    expiresIn: 1,
                    grantType: "grant",
                    refreshToken: "eyj.."
                )
            )
        )
    }
    
    func loginWithApple(idToken: String) -> Observable<PosePickerUser> {
        return Observable<PosePickerUser>.just(
            .init(
                email: "rudwns3927@gmail.com",
                id: 1,
                nickname: "parkjju",
                token: .init(
                    accessToken: "eyj..",
                    expiresIn: 1,
                    grantType: "grant",
                    refreshToken: "eyj.."
                )
            )
        )
    }
    
    func reissueToken() -> Observable<Token> {
        return Observable<Token>.just(
            .init(
                accessToken: "eyj..",
                expiresIn: 1,
                grantType: "grant",
                refreshToken: "eyj.."
            )
        )
    }
    
    func logout() -> Observable<MeaninglessResponse> {
        return Observable<MeaninglessResponse>.just(
            .init(
                entity: "entity",
                message: "message",
                redirect: "redirect",
                status: 200
            )
        )
    }
    
    func deleteUserInfo(withdrawalReason: String) -> Observable<MeaninglessResponse> {
        return Observable<MeaninglessResponse>.just(
            .init(
                entity: "entity",
                message: "message",
                redirect: "redirect",
                status: 200
            )
        )
    }
}
