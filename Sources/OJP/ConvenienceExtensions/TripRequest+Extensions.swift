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

extension OJPv2.PlaceRefChoice: Hashable {
    public static func == (lhs: OJPv2.PlaceRefChoice, rhs: OJPv2.PlaceRefChoice) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .stopPlaceRef(stopPlaceRef):
            hasher.combine(stopPlaceRef.stopPlaceRef)
        case let .geoPosition(geoPositionRef):
            hasher.combine(geoPositionRef.geoPosition.latitude)
            hasher.combine(geoPositionRef.geoPosition.longitude)
        case let .stopPointRef(stopPointRef):
            hasher.combine(stopPointRef.stopPointRef)
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
        case let .continous(continousLeg):
            continousLeg.legStart.title
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
        case let .continous(continousLeg):
            continousLeg.legEnd.title
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

    func hasSituation(trip: OJPv2.Trip) -> Bool {
        guard !ptSituations.isEmpty else { return false }
        return tripResults
            .compactMap(\.trip)
            .contains { trip in
                trip.legs.contains { leg in
                    guard case let .timed(timedLeg) = leg.legType else {
                        return false
                    }
                    return !timedLeg.relevantPtSituations(allPtSituations: ptSituations).isEmpty
                }
            }
    }
}

public extension OJPv2.Trip {
    func hasSituation(allPtSituations: [OJPv2.PTSituation]) -> Bool {
        guard !allPtSituations.isEmpty else { return false }
        return legs.contains { leg in
            guard case let .timed(timedLeg) = leg.legType else {
                return false
            }
            return !timedLeg.relevantPtSituations(allPtSituations: allPtSituations).isEmpty
        }
    }

    /// Returns all ``OJPv2/PTSituation`` that occur any of the ``OJPv2/TimedLeg`` of this trip uniqued by ``OJPv2/PTSituation/situationNumber``.
    func relevantPtSituations(allPtSituations: [OJPv2.PTSituation]) -> [OJPv2.PTSituation] {
        guard !allPtSituations.isEmpty else { return [] }
        return timedLegs.compactMap { timedLeg in
            timedLeg.relevantPtSituations(allPtSituations: allPtSituations)
        }
        .flatMap { $0 }
        .unique(by: \.situationNumber)
    }

    /// Returns only timed legs of a trip.
    var timedLegs: [OJPv2.TimedLeg] {
        legs.compactMap { leg in
            guard case let .timed(timedLeg) = leg.legType else { return nil }
            return timedLeg
        }
    }
}

public extension OJPv2.TimedLeg {
    func relevantPtSituations(allPtSituations: [OJPv2.PTSituation]) -> [OJPv2.PTSituation] {
        service.situationFullRefs?.situationFullRefs.flatMap { serviceSituationRef in
            allPtSituations.filter { $0.situationNumber == serviceSituationRef.situationNumber }
        } ?? []
    }
}
