//
//  TripRequest+Extensions.swift
//
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Foundation

public extension OJPv2.PlaceRefChoice {
    var title: String {
        switch self {
        case let .geoPosition(ref):
            ref.name.text
        case let .stopPointRef(ref):
            ref.name.text
        case let .stopPlaceRef(ref):
            ref.name.text
        }
    }
}

public extension OJPv2.PlaceResult {
    var title: String {
        switch place.place {
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceName.text
        case let .address(address):
            address.name.text
        }
    }

    var placeRef: OJPv2.PlaceRefChoice {
        switch place.place {
        case let .stopPlace(stopPlace):
            .stopPlaceRef(
                .init(
                    stopPlaceRef: stopPlace.stopPlaceRef,
                    name: stopPlace.stopPlaceName
                )
            )
        case let .address(address):
            .geoPosition(
                .init(
                    geoPosition: place.geoPosition,
                    name: address.name
                )
            )
        }
    }
}

public extension OJPv2.Trip {
    var originName: String {
        switch legs.first?.legType {
        case .continous:
            "continuousLeg not implemented"
        case let .timed(timedLeg):
            timedLeg.legBoard.stopPointName.text
        case let .transfer(transferLeg):
            transferLeg.legStart.title
        case nil:
            ""
        }
    }

    var destinationName: String {
        switch legs.last?.legType {
        case .continous:
            "continuousLeg not implemented"
        case let .timed(timedLeg):
            timedLeg.legAlight.stopPointName.text
        case let .transfer(transferLeg):
            transferLeg.legEnd.title
        case nil:
            ""
        }
    }

    var legCount: Int {
        legs.count
    }
}

// MARK: - Situations

public extension OJPv2.TripDelivery {
    /// convenience property for ``OJPv2/PTSituation``.
    var ptSituations: [OJPv2.PTSituation] {
        tripResponseContext?.situations.ptSituations ?? []
    }
}

public extension OJPv2.TimedLeg {
    func relevantPtSituations(allPtSituations: [OJPv2.PTSituation]) -> [OJPv2.PTSituation] {
        service.situationFullRefs?.situationFullRefs.flatMap { serviceSituationRef in
            allPtSituations.filter { $0.situationNumber == serviceSituationRef.situationNumber }
        } ?? []
    }
}
