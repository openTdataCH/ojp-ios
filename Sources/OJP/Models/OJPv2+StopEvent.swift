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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopEventParamStructure)
    struct StopEventParam: Codable, Sendable {
//        public let modeFilter: ModeFilter
        public let includeRealtimeData: Bool?
        public let includeOnwardCalls: Bool?
        public let includePreviousCalls: Bool?
        public let useRealtimeData: UseRealtimeData?

        public enum CodingKeys: String, CodingKey {
            case includeRealtimeData = "IncludeRealtimeData"
            case includeOnwardCalls = "IncludeOnwardCalls"
            case includePreviousCalls = "IncludePreviousCalls"
//            case modeFilter = "ModeFilter"
            case useRealtimeData = "UseRealtimeData"
        }

        public init(includeRealtimeData: Bool?, includeOnwardCalls: Bool?, includePreviousCalls: Bool?, useRealtimeData: UseRealtimeData?) {
            self.includeRealtimeData = includeRealtimeData
            self.includeOnwardCalls = includeOnwardCalls
            self.includePreviousCalls = includePreviousCalls
            self.useRealtimeData = useRealtimeData
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPStopEventDeliveryStructure)
    struct StopEventDelivery: Codable, Sendable {
        public let stopEventResponseContext: ResponseContext?
        public let stopEventResult: [StopEventResult] // TODO: rename it to stopEventResults?

        public enum CodingKeys: String, CodingKey {
            case stopEventResponseContext = "StopEventResponseContext"
            case stopEventResult = "StopEventResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopEventResponseContext = try container.decodeIfPresent(ResponseContext.self, forKey: .stopEventResponseContext)
            stopEventResult = (try? container.decode([OJPv2.StopEventResult].self, forKey: .stopEventResult)) ?? []
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

    struct CallAtNearStop: Codable, Sendable {
        public let callAtStop: CallAtStop
        public let walkDistance: Int?

        public enum CodingKeys: String, CodingKey {
            case callAtStop = "CallAtStop"
            case walkDistance = "WalkDistance"
        }
    }
}
