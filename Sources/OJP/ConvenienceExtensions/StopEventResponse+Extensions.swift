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

    var isSameStop: Bool {
        Set(stopEventResults.map(\.stopEvent.thisCall.stopPoint.stopPointName)).count == 1
    }
}
