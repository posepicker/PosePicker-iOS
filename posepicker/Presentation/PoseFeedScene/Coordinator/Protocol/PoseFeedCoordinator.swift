//
//  PoseFeedCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import Foundation
import RxSwift

protocol PoseFeedCoordinator: Coordinator {
    var loginDelegate: CoordinatorLoginDelegate? { get set }
    func presentFilterModal(currentTags: [String])
    func dismissFilterModal(registeredTags: [String])
    func presentTagResetConfirmModal(disposeBag: DisposeBag) -> Observable<Bool>
    func presentTagRemovePopup(title: String, disposeBag: DisposeBag) -> Observable<String?>
    func presentPoseDetail(viewModel: PoseFeedPhotoCellViewModel)
    func presentClipboardCompleted(poseId: Int)
    func moveToExternalApp(url: URL)
    func dismissPoseDetail(tag: String)
    func presentPoseUploadGuideline()
}
