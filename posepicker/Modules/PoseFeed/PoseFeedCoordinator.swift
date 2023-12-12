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
    
    func pushBookmarkDetailView(viewController: BookmarkDetailViewController) {
        self.navigationController.present(viewController, animated: true)
    }
    
    func dismissBookmarkDetailWithTagSelection(tag: String) {
        guard let root = self.navigationController.viewControllers.first as? RootViewController,
              let navigationVC = root.viewControllers.last as? UINavigationController,
              let posefeedViewController = navigationVC.viewControllers.first as? PoseFeedViewController else { return }
        root.currentPage = 2
        posefeedViewController.loadViewIfNeeded()
        
        // 셀렉션 초기화
        self.poseFeedFilterViewController.loadViewIfNeeded()
        self.poseFeedFilterViewController.detailViewDismissTrigger.onNext(())
        self.poseFeedFilterViewController.registeredSubTag.accept(nil)
        self.poseFeedFilterViewController.subTagRemoveTrigger.onNext(())
        
        if let _ = PeopleCountTags.getTagFromTitle(title: tag) {
            // 1. 인원 수 태그인 경우
            guard let peopleCountIndex = PeopleCountTags.getNumberFromPeopleCountString(countString: tag) else { return }
            self.poseFeedFilterViewController.headCountSelection.buttonTapTrigger
                .accept(peopleCountIndex)
        } else if let _ = FrameCountTags.getTagFromTitle(title: tag) {
            // 2. 프레임 수 태그인 경우
            guard let frameCountIndex = FrameCountTags.getIndexFromFrameCountString(countString: tag) else { return }
            self.poseFeedFilterViewController.frameCountSelection.buttonTapTrigger.accept(frameCountIndex)
        } else if let filteredTag = FilterTags.getTagFromTitle(title: tag) {
            self.poseFeedFilterViewController.filteredTagAfterDismiss.accept(filteredTag)
        } else {
            // 3. 서브태그인 경우
            self.poseFeedFilterViewController.registeredSubTag.accept(tag)
        }
        posefeedViewController.modalDismissWithTag.onNext(tag)
        posefeedViewController.registerButtonTapped.onNext(())
        
        self.navigationController.popViewController(animated: true)
    }
    
    func dismissPoseDetailWithTagSelection(tag: String) {
        guard let posefeedViewController = self.navigationController.viewControllers.first as? PoseFeedViewController else { return }
        
        // 셀렉션 초기화
        self.poseFeedFilterViewController.loadViewIfNeeded()
        self.poseFeedFilterViewController.detailViewDismissTrigger.onNext(())
        self.poseFeedFilterViewController.registeredSubTag.accept(nil)
        self.poseFeedFilterViewController.subTagRemoveTrigger.onNext(())
        
        if let _ = PeopleCountTags.getTagFromTitle(title: tag) {
            // 1. 인원 수 태그인 경우
            guard let peopleCountIndex = PeopleCountTags.getNumberFromPeopleCountString(countString: tag) else { return }
            self.poseFeedFilterViewController.headCountSelection.buttonTapTrigger
                .accept(peopleCountIndex)
        } else if let _ = FrameCountTags.getTagFromTitle(title: tag) {
            // 2. 프레임 수 태그인 경우
            guard let frameCountIndex = FrameCountTags.getIndexFromFrameCountString(countString: tag) else { return }
            self.poseFeedFilterViewController.frameCountSelection.buttonTapTrigger.accept(frameCountIndex)
        } else if let filteredTag = FilterTags.getTagFromTitle(title: tag) {
            self.poseFeedFilterViewController.filteredTagAfterDismiss.accept(filteredTag)
        } else {
            // 3. 서브태그인 경우
            self.poseFeedFilterViewController.registeredSubTag.accept(tag)
        }
        posefeedViewController.modalDismissWithTag.onNext(tag)
        posefeedViewController.registerButtonTapped.onNext(())
    }
}
