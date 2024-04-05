//
//  DefaultPoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultPoseFeedCoordinator: PoseFeedCoordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var posefeedViewController: PoseFeedViewController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .posetalk
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.posefeedViewController = PoseFeedViewController()
    }
    
    func start() {
        self.posefeedViewController.viewModel = PoseFeedViewModel(
            coordinator: self,
            posefeedUseCase: DefaultPoseFeedUseCase(
                posefeedRepository: DefaultPoseFeedRepository(
                    networkService: DefaultNetworkService()
                )
            )
        )
        
        self.navigationController.pushViewController(self.posefeedViewController, animated: true)
    }
    
    func presentFilterModal(currentTags: [String]) {
        let posefeedFilterViewController = PoseFeedFilterViewController()
        
        posefeedFilterViewController.viewModel = PoseFeedFilterViewModel(
            coordinator: self,
            posefeedFilterUseCase: DefaultPoseFeedFilterUseCase(),
            currentTags: currentTags
        )
        
        if let sheet = posefeedFilterViewController.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 476 })]
            sheet.preferredCornerRadius = 20
        }
        
        self.navigationController.present(posefeedFilterViewController, animated: true)
    }
    
    func dismissFilterModal(registeredTags: [String]) {
        self.navigationController.dismiss(animated: true)
        self.posefeedViewController.dismissFilterModalEvent.onNext(
            registeredTags.map {
                RegisteredFilterCellViewModel(title: $0)
            }
        )
    }
    
    func presentTagResetConfirmModal(disposeBag: DisposeBag) -> Observable<Bool> {
        let isConfirmed = BehaviorRelay<Bool>(value: false)
        
        let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: true)
        guard let popupView = popupVC.popUpView as? PopUpView else { return Observable<Bool>.empty() }
        popupView.alertText.accept("필터를 초기화하시겠습니까?")
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        popupView.cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController.presentedViewController?.dismiss(animated: true)
                isConfirmed.accept(false)
            })
            .disposed(by: disposeBag)
        
        popupView.confirmButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                isConfirmed.accept(true)
                self?.navigationController.presentedViewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.navigationController.presentedViewController?.present(popupVC, animated: true)
        
        return isConfirmed.asObservable()
    }
    
    func presentTagRemovePopup(title:String, disposeBag: DisposeBag) -> Observable<String?> {
        let isConfirmed = BehaviorRelay<String?>(value: nil)
        
        let popupVC = PopUpViewController(isLoginPopUp: false, isChoice: true)
        guard let popupView = popupVC.popUpView as? PopUpView else { return Observable<String?>.empty() }
        popupView.alertText.accept("필터를 삭제하시겠습니까?")
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        popupView.cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController.dismiss(animated: true)
                isConfirmed.accept(nil)
            })
            .disposed(by: disposeBag)
        
        popupView.confirmButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                isConfirmed.accept(title)
                self?.navigationController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.navigationController.present(popupVC, animated: true)
        
        return isConfirmed.asObservable()
    }
}
