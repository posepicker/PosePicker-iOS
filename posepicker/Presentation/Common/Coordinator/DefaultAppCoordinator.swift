//
//  AppCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/21.
//

import UIKit

class DefaultAppCoordinator: AppCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType { .app }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    func start() {
        self.showPageviewFlow()
    }
    
    func showPageviewFlow() {
        let pageviewCoordinator = DefaultPageViewCoordinator(self.navigationController)
        pageviewCoordinator.finishDelegate = self
        pageviewCoordinator.start()
        childCoordinators.append(pageviewCoordinator)
        
        // 앱 버전 확인
        if Bundle.main.releaseVersionNumber != "1.0.7" && !UserDefaults.standard.bool(forKey: "updateBefore") {
            let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: true)
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            self.navigationController.present(popupVC, animated: true)
            
            if let popupView = popupVC.popUpView as? PopUpView {
                popupView.alertText.accept("앱의 최신 버전이 필요합니다.\n업데이트 해주세요.")
                popupView.snp.updateConstraints { make in
                    make.height.equalTo(158 + "앱의 최신 버전이 필요합니다.\n업데이트 해주세요.".height(withConstrainedWidth: 300, font: .pretendard(.regular, ofSize: 16)))
                }
                
                popupView.cancelButton.setTitle("나중에", for: .normal)
                
                popupView.cancelButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                    })
                    .disposed(by: popupVC.disposeBag)
                
                popupView.confirmButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        if let url = URL(string: "https://apps.apple.com/kr/app/%ED%8F%AC%EC%A6%88%ED%94%BC%EC%BB%A4-%EB%84%A4%EC%BB%B7%EC%82%AC%EC%A7%84-%ED%8F%AC%EC%A6%88%EC%B6%94%EC%B2%9C/id6474260471") {
                            UIApplication.shared.open(url)
                        }
                        
                        self?.navigationController.dismiss(animated: true)
                    })
                    .disposed(by: popupVC.disposeBag)
            }
            
            UserDefaults.standard.set(true, forKey: "updateBefore")
        }
    }
    
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0.type != childCoordinator.type })
        
        self.navigationController.view.backgroundColor = .systemBackground
        self.navigationController.viewControllers.removeAll()
    }
}
