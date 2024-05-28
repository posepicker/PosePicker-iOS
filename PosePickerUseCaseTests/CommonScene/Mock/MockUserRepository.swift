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
    
    let errorWithLogout: Bool
    let expiredWithLogout: Bool
    let errorWithDeleteUser: Bool
    
    init(errorWithLogout: Bool = false, expiredWithLogout: Bool = false, errorWithDeleteUser: Bool = false) {
        self.errorWithLogout = errorWithLogout
        self.expiredWithLogout = expiredWithLogout
        self.errorWithDeleteUser = errorWithDeleteUser
    }
    
    func logout(with: LoginPopUpView.SocialLogin, disposeBag: DisposeBag) -> Observable<posepicker.LogoutResponse> {
        
        if expiredWithLogout {
            print("EXPIRED WITH ..")
            return .just(
                .init(
                    entity: "error",
                    message: "error",
                    status: 401
                )
            )
        }
        
        if errorWithLogout {
            print("ERROR WITH ..")
            return .error(
                APIError.http(status: 401)
            )
        }
        
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
    
    func deleteUserInfo(with: LoginPopUpView.SocialLogin, withdrawalReason: String, disposeBag: DisposeBag) -> Observable<MeaninglessResponse> {
        
        if errorWithDeleteUser {
            return .just(
                .init(
                    entity: "ERROR",
                    message: "ERROR",
                    redirect: "ERROR",
                    status: 500
                )
            )
        }
        
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
