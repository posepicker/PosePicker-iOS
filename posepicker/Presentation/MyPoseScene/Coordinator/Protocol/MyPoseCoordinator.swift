//
//  MyPoseCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 4/10/24.
//

import UIKit

protocol MyPoseCoordinator: Coordinator {
    func pushGuideline()
    func presentImageLoadFailedPopup()
    func pushMyPoseView(image: UIImage?)
}
