//
//  MyPoseProtocol.swift
//  posepicker
//
//  Created by 박경준 on 4/30/24.
//

import UIKit

protocol MyPoseCoordinator: Coordinator {
    var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate? { get set }
    func presentBookmarkDetail(viewModel: BookmarkFeedCellViewModel)
    func presentClipboardCompleted(poseId: Int)
    func moveToExternalApp(url: URL)
    func dismissPoseDetail(tag: String)
    
    func viewControllerBefore() -> UIViewController?
    func viewControllerAfter() -> UIViewController?
}
