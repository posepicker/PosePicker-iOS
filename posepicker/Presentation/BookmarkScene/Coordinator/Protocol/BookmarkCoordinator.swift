//
//  BookmarkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/8/24.
//

import Foundation

protocol BookmarkCoordinator: Coordinator {
    var bookmarkBindingDelegate: CoordinatorBookmarkBindingDelegate? { get set }
    func presentBookmarkDetail(viewModel: BookmarkFeedCellViewModel)
    func presentClipboardCompleted(poseId: Int)
    func moveToExternalApp(url: URL)
    func dismissPoseDetail(tag: String)
}
