//
//  PoseTalkCoordinator.swift
//  posepicker
//
//  Created by 박경준 on 3/27/24.
//

import Foundation

protocol PoseTalkCoordinator: Coordinator {
    var tooltipDelegate: CoordinatorTooltipDelegate? { get set }
    func toggleTooltip()
    func addTooltip()
    func removeTooltip()
}
