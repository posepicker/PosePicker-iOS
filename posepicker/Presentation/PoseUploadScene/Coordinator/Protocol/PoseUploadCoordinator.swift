//
//  MyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

protocol PoseUploadCoordinator: Coordinator {
    func pushGuideline()
    func presentImageLoadFailedPopup()
    func pushPoseUploadView(image: UIImage?)
}
