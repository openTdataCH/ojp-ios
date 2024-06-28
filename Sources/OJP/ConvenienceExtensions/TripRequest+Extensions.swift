//
//  TripResult+Extensions.swift
//
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Foundation

public extension OJPv2.PlaceRefChoice {
    var title: String {
        switch self {
        case let .stopPointRef(_, name), 
            let .stopPlaceRef(_, name),
            let .geoPosition(_, name):
            return name.text
        }
    }
}

public extension OJPv2.Trip {
    var originName: String {
        switch legs.first?.legType {
        case .continous(let continuousLeg):
            ""
        case .timed(let timedLeg):
            timedLeg.legBoard.stopPointName.text
        case .transfer(let transferLeg):
            transferLeg.legStart.title
        case nil:
            ""
        }
    }

    var destinationName: String {
        switch legs.last?.legType {
        case .continous(let continuousLeg):
            ""
        case .timed(let timedLeg):
            timedLeg.legAlight.stopPointName.text
        case .transfer(let transferLeg):
            transferLeg.legEnd.title
        case nil:
            ""
        }
    }

    var legCount: Int {
        legs.count
    }
}
