//
//  OccupancyLevel+Extensions.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 26.06.2025.
//
import OEVIcons
import OJP
import SwiftUI

extension OJPv2.OccupancyLevel {
    var icon: Image {
        switch self {
        case .unknown:
            OEVIcons.utilization_none
        case .empty:
            OEVIcons.utilization_none
        case .manySeatsAvailable:
            OEVIcons.utilization_low
        case .fewSeatsAvailable:
            OEVIcons.utilization_medium
        case .standingRoomOnly:
            OEVIcons.utilization_high
        case .crushedStandingRoomOnly:
            OEVIcons.utilization_high
        case .full:
            OEVIcons.utilization_high
        case .notAcceptingPassengers:
            OEVIcons.utilization_high
        case .undefined:
            OEVIcons.utilization_none
        }
    }
}
