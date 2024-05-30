//
//  MockPoseFeedCoordinator.swift
//  PosePickerViewModelTests
//
//  Created by 박경준 on 5/30/24.
//

import UIKit
import RxSwift

@testable import posepicker
final class MockPoseFeedCoordinator: PoseFeedCoordinator {
    var loginDelegate: CoordinatorLoginDelegate?
    var bookmarkContentsUpdatedDelegate: CoordinatorBookmarkContentsUpdateDelegate?
    
    func presentFilterModal(currentTags: [String]) {
        
    }
    
    func dismissFilterModal(registeredTags: [String]) {
        
    }
    
    func presentTagResetConfirmModal(disposeBag: DisposeBag) -> Observable<Bool> {
        return .just(true)
    }
    
    func presentTagRemovePopup(title: String, disposeBag: DisposeBag) -> Observable<String?> {
        return .just(title)
    }
    
    func presentPoseDetail(viewModel: PoseFeedPhotoCellViewModel) {
        
    }
    
    func presentClipboardCompleted(poseId: Int) {
        
    }
    
    func moveToExternalApp(url: URL) {
        
    }
    
    func dismissPoseDetail(tag: String) {
        
    }
    
    func presentPoseUploadGuideline() {
        
    }
    
    func presentReportView(poseId: Int) {
        
    }
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [any posepicker.Coordinator]
    
    var type: posepicker.CoordinatorType
    
    func start() {
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.type = .posefeed
    }
    
    
}
