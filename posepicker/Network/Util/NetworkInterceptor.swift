//
//  APIInterceptor.swift
//  posepicker
//
//  Created by Jun on 2023/10/24.
//

import Foundation

import Alamofire
import RxSwift
import UIKit

class APIInterceptor: RequestInterceptor {
    var disposeBag = DisposeBag()
    var apiSession: NetworkService = DefaultNetworkService()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        if let url = urlRequest.url,
           let accessToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.accessToken),
           let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.Parameters.refreshToken) {
            
            if url.absoluteString.contains("/api/pose") || url.absoluteString.contains("/api/pose/all") || url.absoluteString.contains("/api/bookmark") ||
                url.absoluteString.contains("/api/pose/mypose") ||
                url.absoluteString.contains("/api/pose/user") ||
                url.absoluteString.contains("/api/users/logout") ||
                (url.absoluteString.contains("/api/pose/") && urlRequest.method == .post) {
                var urlRequest = urlRequest
                urlRequest.headers.add(.authorization(bearerToken: accessToken))
                completion(.success(urlRequest))
                return
            } else if url.absoluteString.contains("/api/auth/reissue-token") {
                var urlRequest = urlRequest
                urlRequest.headers.add(.authorization(bearerToken: refreshToken))
                completion(.success(urlRequest))
                return
            }
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        // 401이면서 리프레시 토큰이 만료된 상태일때
        if let url = response.url,
           url.absoluteString.contains("/api/auth/reissue-token") {
            KeychainManager.shared.removeAll()
            // 세션만료 ALERT
            DispatchQueue.main.async {
                /// 1. 글로벌 객체로 루트 뷰 컨트롤러 불러오기
                let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
                let root = window?.rootViewController
                
                /// 2. 루트뷰에 팝업 뮤 present하기 위한 객체 생성 및 텍스트 세팅
                let popupViewController = PopUpViewController(isLoginPopUp: false, isChoice: false)
                popupViewController.modalTransitionStyle = .crossDissolve
                popupViewController.modalPresentationStyle = .overFullScreen
                let popupView = popupViewController.popUpView as! PopUpView
                popupView.alertText.accept("세션이 만료되었어요.\n다시 로그인이 필요해요!")
                
                UserDefaults.standard.setValue(false, forKey: K.SocialLogin.isLoggedIn)
                
                /// 3. 루트뷰에 present
                root?.present(popupViewController, animated: true)
                
                /// 4. 루트뷰 서브뷰 first 객체 타입캐스팅 및 접근
                let navVC = root as? UINavigationController
                guard let rootVC = navVC?.viewControllers.first as? CommonViewController else { return }
                
                /// 5. 루트뷰로 popToViewController
                /// completion핸들러 익스텐션에 구현
                /// 포즈피드 뷰 새로고침 진행하고 루트뷰 currentPage 세팅
                
                navVC?.popToViewController(rootVC, animated: true) {
                    rootVC.removeMyPoseContentsTrigger.onNext(())
                    
                    if let posefeedNavVC = rootVC.pageViewController.viewControllers?.last as? UINavigationController,
                       let posefeedVC = posefeedNavVC.viewControllers.first as? PoseFeedViewController {
                        posefeedVC.viewDidLoadEvent.onNext(())
                    }
                    
                    rootVC.segmentControl.rx.selectedSegmentIndex.onNext(0)
                    rootVC.viewModel?.coordinator?.setSelectedIndex(0)
                }
            }
            completion(.doNotRetry)
            return
        } else if let url = response.url,
                  url.absoluteString.contains("/api/users/logout") {
            KeychainManager.shared.removeAll()
            completion(.doNotRetry)
            return
        }
        
        guard let refreshToken = try? KeychainManager.shared.retrieveItem(ofClass: .password, key: K.KeychainKeyParameters.refreshToken) else {
            completion(.doNotRetry)
            return
        }
        
        let refreshTokenObservable: Single<Token> = apiSession.requestSingle(.refreshToken(refreshToken: refreshToken))
        
        refreshTokenObservable
            .asObservable()
            .subscribe(onNext: { token in
                try? KeychainManager.shared.updateItem(with: token.accessToken, ofClass: .password, key: K.KeychainKeyParameters.accessToken)
                try? KeychainManager.shared.updateItem(with: token.refreshToken, ofClass: .password, key: K.KeychainKeyParameters.refreshToken)
                completion(.retry)
            })
            .disposed(by: disposeBag)
    }
}
