//
//  TripRefine+Extension.swift
//  OJP
//
//  Created by Lehnherr Reto on 03.04.2025.
//

import Foundation

public extension OJPv2.TripResult {
    var minimalTripResult: OJPv2.TripResult {
        guard let trip else {
            // ignoring TripSummary
            return self
        }
        return .init(trip: trip.minimalCopy)
    }
}

extension OJPv2.Trip {
    var minimalCopy: Self {
        .init(id: id,
              duration: duration,
              startTime: startTime,
              endTime: endTime,
              transfers: transfers,
              legs: legs.map(\.minimalCopy))
    }
}

extension OJPv2.Leg {
    var minimalCopy: Self {
        .init(
            id: id,
            duration: duration, // optional but required
            legType: legType.minimalCopy
        )
    }
}

extension OJPv2.Leg.LegTypeChoice {
    var minimalCopy: Self {
        switch self {
        case let .continous(continuousLeg):
            .continous(continuousLeg.minimalCopy)
        case let .timed(timedLeg):
            .timed(timedLeg.minimalCopy)
        case let .transfer(transferLeg):
            .transfer(transferLeg)
        }
    }
}

extension OJPv2.TimedLeg {
    var minimalCopy: Self {
        .init(
            legBoard: legBoard.minimalCopy,
            legsIntermediate: [], // legsIntermediate,
            legAlight: legAlight.minimalCopy,
            service: service.minimalCopy
        )
    }
}

extension OJPv2.ContinuousLeg {
    var minimalCopy: Self {
        .init(
            legStart: legStart,
            legEnd: legEnd,
            duration: duration,
            service: service.minimalCopy
        )
    }
}

extension OJPv2.ContinuousService {
    var minimalCopy: Self {
        .init(type: type.minimalCopy)
    }
}

extension OJPv2.DatedJourney {
    var minimalCopy: OJPv2.DatedJourney {
        .init(
            //            conventionalModeOfOperation: conventionalModeOfOperation,
            operatingDayRef: operatingDayRef,
            journeyRef: journeyRef,
//            publicCode: publicCode,
            lineRef: lineRef,
            directionRef: directionRef,
            mode: mode,
            productCategory: productCategory,
            publishedServiceName: publishedServiceName,
//            trainNumber: trainNumber,
//            vehicleRef: vehicleRef,
//            attributes: attributes,
//            operatorRef: operatorRef,
            originText: originText
//            originStopPointRef: originStopPointRef,
//            destinationText: destinationText,
//            destinationStopPointRef: destinationStopPointRef,
//            situationFullRefs: situationFullRefs,
//            serviceStatus: serviceStatus
        )
    }
}

extension OJPv2.ContinuousServiceTypeChoice {
    var minimalCopy: Self {
        switch self {
        case let .datedJourney(datedJourney):
            OJPv2.ContinuousServiceTypeChoice.datedJourney(datedJourney.minimalCopy)
        case .personalService:
            self
        }
    }
}

public extension OJPv2.LegBoard {
    var minimalCopy: Self {
        .init(
            stopPointRef: stopPointRef,
            stopPointName: stopPointName,
            serviceDeparture: .init(timetabledTime: serviceDeparture.timetabledTime)
        )
    }
}

extension OJPv2.LegAlight {
    var minimalCopy: Self {
        .init(
            stopPointRef: stopPointRef,
            stopPointName: stopPointName,
            serviceArrival: .init(timetabledTime: serviceArrival.timetabledTime)
        )
    }
}
