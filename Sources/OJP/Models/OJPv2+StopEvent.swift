//
//  OJPv2+StopEvent.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.11.2024.
//

import Foundation
import XMLCoder

public extension OJPv2 {
    /// [Schema documentation on vdvde.github.io]( https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPStopEventRequestStructure)
    struct StopEventRequest: Codable, Sendable {
        public let requestTimestamp: Date
        public let location: PlaceContext
        public let params: StopEventParam?

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case location = "Location"
            case params = "Params"
        }
    }

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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopEventParamStructure)
    struct StopEventParam: Codable, Sendable {
//        public let modeFilter: ModeFilter
        public let includeAllRestrictedLines: Bool?
        public let includeRealtimeData: Bool?
        public let includeOnwardCalls: Bool?
        public let includePreviousCalls: Bool?
        public let useRealtimeData: UseRealtimeData?
        public let stopEventType: StopEventType?
        public let numberOfResults: Int?

        public enum CodingKeys: String, CodingKey {
            case includeAllRestrictedLines = "IncludeAllRestrictedLines"
            case includeRealtimeData = "IncludeRealtimeData"
            case includeOnwardCalls = "IncludeOnwardCalls"
            case includePreviousCalls = "IncludePreviousCalls"
//            case modeFilter = "ModeFilter"
            case useRealtimeData = "UseRealtimeData"
            case stopEventType = "StopEventType"
            case numberOfResults = "NumberOfResults"
        }

        public init(includeAllRestrictedLines: Bool? = true, includeRealtimeData: Bool? = true, includeOnwardCalls: Bool? = false, includePreviousCalls: Bool? = false, useRealtimeData: UseRealtimeData? = .explanatory, stopEventType: StopEventType?, numberOfResults: Int?) {
            self.includeAllRestrictedLines = includeAllRestrictedLines
            self.includeRealtimeData = includeRealtimeData
            self.includeOnwardCalls = includeOnwardCalls
            self.includePreviousCalls = includePreviousCalls
            self.useRealtimeData = useRealtimeData
            self.stopEventType = stopEventType
            self.numberOfResults = numberOfResults
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPStopEventDeliveryStructure)
    struct StopEventDelivery: Codable, Sendable {
        public let stopEventResponseContext: ResponseContext?
        public let stopEventResults: [StopEventResult]

        public enum CodingKeys: String, CodingKey {
            case stopEventResponseContext = "StopEventResponseContext"
            case stopEventResults = "StopEventResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopEventResponseContext = try container.decodeIfPresent(ResponseContext.self, forKey: .stopEventResponseContext)
            stopEventResults = (try? container.decode([OJPv2.StopEventResult].self, forKey: .stopEventResults)) ?? []
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopEventResultStructure
    struct StopEventResult: Codable, Sendable {
        // 😱 https://github.com/openTdataCH/ojp-sdk/issues/173
        // public let id: String
        public let stopEvent: StopEvent

        public enum CodingKeys: String, CodingKey {
//            case id = "Id"
            case stopEvent = "StopEvent"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopEventTypeEnumeration)
    enum StopEventType: String, Codable, Sendable {
        case departure
        case arrival
        case both
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopEventStructure)
    struct StopEvent: Codable, Sendable {
        public let previousCall: CallAtNearStop?
        public let thisCall: CallAtNearStop
        public let onwardCall: CallAtNearStop?
        public let service: DatedJourney

        public enum CodingKeys: String, CodingKey {
            case previousCall = "PreviousCall"
            case thisCall = "ThisCall"
            case onwardCall = "OnwardCall"
            case service = "Service"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__CallAtNearStopStructure)
    struct CallAtNearStop: Codable, Sendable {
        public let callAtStop: CallAtStop
        public let walkDistance: Int?

        public enum CodingKeys: String, CodingKey {
            case callAtStop = "CallAtStop"
            case walkDistance = "WalkDistance"
        }
    }
}
