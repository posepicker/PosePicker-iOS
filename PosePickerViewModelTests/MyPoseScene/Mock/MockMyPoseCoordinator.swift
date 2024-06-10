//
//  MockMyPoseCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 6/3/24.
//

import UIKit
@testable import posepicker

final class MockMyPoseCoordinator: MyPoseCoordinator {
    private let posefeedCoordinator = MockPoseFeedCoordinator(
        UINavigationController(
            rootViewController: UIViewController()
        )
    )
    
    var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate?
    
    var pageMoveDelegate: CoordinatorPageMoveDelegate?
    
    func presentBookmarkDetail(viewModel: posepicker.BookmarkFeedCellViewModel) {
        print(#function)
    }
    
    func presentClipboardCompleted(poseId: Int) {
        print(#function)
    }
    
    func moveToExternalApp(url: URL) {
        print(#function)
    }
    
    func dismissPoseDetail(tag: String) {
        print(#function)
    }
    
    func currentPage() -> MyPosePageViewType? {
        return nil
    }
    
    func setSelectedIndex(_ index: Int) {
        print(#function)
    }
    
    func viewControllerBefore() -> UIViewController? {
        return nil
    }
    
    func viewControllerAfter() -> UIViewController? {
        return nil
    }
    
    func refreshBookmark() {
        print(#function)
    }
    
    func refreshPoseCount() {
        print(#function)
    }
    
    func removeAllContents() {
        print(#function)
    }
    
    func presentPoseUploadGuideline() {
        print(#function)
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
