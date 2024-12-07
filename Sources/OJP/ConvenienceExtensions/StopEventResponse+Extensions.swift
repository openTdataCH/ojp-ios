//
//  StopEventResponse+Extensions.swift
//  OJP
//
//  Created by Lehnherr Reto on 27.11.2024.
//

import Foundation

public extension OJPv2.CallAtStop {
    var stopPoint: OJPv2.StopPoint {
        .init(stopPointRef: stopPointRef, stopPointName: stopPointName, parentRef: nil, topographicPlaceRef: nil)
    }
}

public extension OJPv2.CallAtNearStop {
    var stopPoint: OJPv2.StopPoint {
        callAtStop.stopPoint
    }
}

public extension OJPv2.StopEventDelivery {
    /// convenience property for ``OJPv2/PTSituation``.
    var ptSituations: [OJPv2.PTSituation] {
        stopEventResponseContext?.situations?.ptSituations ?? []
    }

    /// Groups StopEvents by `stopPointName`
    var stopEventsGroupedByStation: [String: [OJPv2.StopEventResult]] {
        stopEventResults.reduce(into: [:]) { partialResult, stopEventResult in
            let currentStop = stopEventResult.stopEvent.thisCall.stopPoint.stopPointName.text
            if var current = partialResult[currentStop] {
                current.append(stopEventResult)
                partialResult[currentStop] = current
            } else {
                partialResult[currentStop] = [stopEventResult]
            }
        }
    }

    /// Use `stopPointName` to group StopEvents by stations as different quays of the same Stop have different ids
    var isSameStop: Bool {
        Set(stopEventResults.map(\.stopEvent.thisCall.stopPoint.stopPointName)).count == 1
    }
}

public extension OJPv2.StopEvent {
    func relevantPtSituations(allPtSituations: [OJPv2.PTSituation]) -> [OJPv2.PTSituation] {
        let uniqueSituations = allPtSituations.unique(by: \.situationNumber)
        guard !uniqueSituations.isEmpty else { return [] }
        return service.situationFullRefs?.situationFullRefs.flatMap { serviceSituationRef in
            uniqueSituations.filter { $0.situationNumber == serviceSituationRef.situationNumber }
        } ?? []
    }

    func hasSituation(allPtSituations: [OJPv2.PTSituation]) -> Bool {
        !relevantPtSituations(allPtSituations: allPtSituations).isEmpty
    }
}
