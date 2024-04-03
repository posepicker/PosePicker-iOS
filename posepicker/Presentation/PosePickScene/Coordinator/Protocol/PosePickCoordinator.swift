//
//  PosePickCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import UIKit

protocol PosePickCoordinator: Coordinator {
    func presentDetailImage(retrievedImage: UIImage?)
}
