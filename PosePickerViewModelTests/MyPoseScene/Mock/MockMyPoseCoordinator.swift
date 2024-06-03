//
//  MockMyPoseCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/3/24.
//

import UIKit
@testable import posepicker

final class MockMyPoseCoordinator: MyPoseCoordinator {
    private let posefeedCoordinator = MockPoseFeedCoordinator(UINavigationController(rootViewController: UIViewController()))
    
    var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate?
    
    var pageMoveDelegate: CoordinatorPageMoveDelegate?
    
    func presentBookmarkDetail(viewModel: posepicker.BookmarkFeedCellViewModel) {
        
    }
    
    func presentClipboardCompleted(poseId: Int) {
        
    }
    
    func moveToExternalApp(url: URL) {
        
    }
    
    func dismissPoseDetail(tag: String) {
        
    }
    
    func currentPage() -> MyPosePageViewType? {
        return .saved
    }
    
    func setSelectedIndex(_ index: Int) {
        
    }
    
    func viewControllerBefore() -> UIViewController? {
        return nil
    }
    
    func viewControllerAfter() -> UIViewController? {
        return nil
    }
    
    func refreshBookmark() {
        
    }
    
    func refreshPoseCount() {
        
    }
    
    func removeAllContents() {
        
    }
    
    func presentPoseUploadGuideline() {
        
    }
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController = UINavigationController(rootViewController: UIViewController())
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .mypose
    
    func start() {
        self.bookmarkBindingDelegate = self.posefeedCoordinator
    }
    
    init(_ navigationController: UINavigationController) {
        
    }
}
