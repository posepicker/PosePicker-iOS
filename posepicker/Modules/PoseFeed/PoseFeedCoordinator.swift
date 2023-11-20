//
//  PoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 2023/10/26.
//

import UIKit

class PoseFeedCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var poseFeedFilterViewController = PoseFeedFilterViewController(viewModel: PoseFeedFilterViewModel())
    
    // MARK: - Initialization
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Functions
    
    func start() { }
    
    func presentModal() {
        if let sheet = poseFeedFilterViewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 476}]
            sheet.preferredCornerRadius = 20
        }
        
        navigationController.viewControllers.first?.present(poseFeedFilterViewController, animated: true)
    }
    
    func pushDetailView(viewController: PoseDetailViewController) {
        self.navigationController.present(viewController, animated: true)
    }
    
    func dismissPoseDetailWithTagSelection(tag: String) {
        guard let posefeedViewController = self.navigationController.viewControllers.first as? PoseFeedViewController else { return }
        
        if let peopleCountTag = PeopleCountTags.getTagFromTitle(title: tag) {
            // 1. 인원 수 태그인 경우
            self.poseFeedFilterViewController.selectedHeadCount.accept(peopleCountTag)
        } else if let frameCountTag = FrameCountTags.getTagFromTitle(title: tag) {
            // 2. 프레임 수 태그인 경우
            self.poseFeedFilterViewController.selectedFrameCount.accept(frameCountTag)
        } else {
            // 3. 서브태그인 경우
            self.poseFeedFilterViewController.registeredSubTag.accept(tag)
        }
        
        // 셀렉션 초기화
        self.poseFeedFilterViewController.detailViewDismissTrigger.onNext(())
        
        posefeedViewController.modalDismissWithTag.onNext(tag)
    }
}
