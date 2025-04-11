//
//  OJPv2+TripRefine.swift
//  OJP
//
//  Created by Lehnherr Reto on 09.04.2025.
//

import Foundation

public extension OJPv2 {
    struct TripRefineRequest: Codable, Sendable {
        public let requestTimestamp: Date
        public let params: TripRefineParams

        public let tripResult: OJPv2.TripResult

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case tripResult = "TripResult"
            case params = "Params"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripRefineParamStructure)
    /// - Note: It is mostly identical to ``OJPv2/TripParams``, so we use a typelias until custom properties are needed.
    typealias TripRefineParams = TripParams

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPTripRefineDeliveryStructure)
    /// - Note: It is mostly identical to ``OJPv2/TripDelivery``, so we use a typelias until custom properties are needed.
    typealias TripRefineDelivery = TripDelivery
}

public extension OJPv2.TripRefineParams {
    static var defaultTripRefineParams: Self {
        .init(includeIntermediateStops: true, includeAllRestrictedLines: true, useRealtimeData: .explanatory)
    }
}
