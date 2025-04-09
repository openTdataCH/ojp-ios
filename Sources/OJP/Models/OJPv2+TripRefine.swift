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
    struct TripRefineParams: Codable, Sendable {
        public init(includeTrackSections: Bool? = false, includeLegProjection: Bool? = false, includeTurnDescription: Bool? = false, includeIntermediateStops: Bool? = true, includeAllRestrictedLines: Bool? = true, useRealtimeData: UseRealtimeData? = .explanatory) {
            self.includeTrackSections = includeTrackSections
            self.includeLegProjection = includeLegProjection
            self.includeTurnDescription = includeTurnDescription
            self.includeIntermediateStops = includeIntermediateStops
            self.includeAllRestrictedLines = includeAllRestrictedLines
            self.useRealtimeData = useRealtimeData
        }

        public enum CodingKeys: String, CodingKey {
            case includeTrackSections = "IncludeTrackSections"
            case includeLegProjection = "IncludeLegProjection"
            case includeTurnDescription = "IncludeTurnDescription"
            case includeIntermediateStops = "IncludeIntermediateStops"
            case includeAllRestrictedLines = "IncludeAllRestrictedLines"
            case useRealtimeData = "UseRealtimeData"
        }

        public let includeTrackSections: Bool?
        public let includeLegProjection: Bool?
        public let includeTurnDescription: Bool?
        public let includeIntermediateStops: Bool?
        public let includeAllRestrictedLines: Bool?
        public let useRealtimeData: UseRealtimeData?
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPTripRefineDeliveryStructure)
    struct TripRefineDelivery: Codable, Sendable {
        // TODO: Add custom props
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let calcTime: Int?
        public let tripResponseContext: ResponseContext?
        public internal(set) var tripResults: [TripResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case calcTime = "CalcTime"
            case tripResponseContext = "TripResponseContext"
            case tripResults = "TripResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            responseTimestamp = try container.decode(String.self, forKey: .responseTimestamp)
            requestMessageRef = try container.decodeIfPresent(String.self, forKey: .requestMessageRef)
            calcTime = try container.decodeIfPresent(Int.self, forKey: .calcTime)
            tripResponseContext = try container.decodeIfPresent(OJPv2.ResponseContext.self, forKey: .tripResponseContext)
            tripResults = try (container.decodeIfPresent([OJPv2.TripResult].self, forKey: .tripResults)) ?? [] // tripResults could be optional
        }
    }

}
