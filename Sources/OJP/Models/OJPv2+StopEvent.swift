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
        public let modeFilter: ModeFilter?
        public let lineFilter: LineDirectionFilter?
        public let operatorFilter: OperatorFilter?
        public let includeAllRestrictedLines: Bool?
        public let numberOfResults: Int?
        public let stopEventType: StopEventType?
        public let includePreviousCalls: Bool?
        public let includeOnwardCalls: Bool?
        public let includeOperatingDays: Bool?
        public let useRealtimeData: UseRealtimeData?
        public let includePlacesContext: Bool?
        public let includeSituationsContext: Bool?

        public enum CodingKeys: String, CodingKey {
            case modeFilter = "ModeFilter"
            case lineFilter = "LineFilter"
            case operatorFilter = "OperatorFilter"
            case includeAllRestrictedLines = "IncludeAllRestrictedLines"
            case numberOfResults = "NumberOfResults"
            case stopEventType = "StopEventType"
            case includePreviousCalls = "IncludePreviousCalls"
            case includeOnwardCalls = "IncludeOnwardCalls"
            case includeOperatingDays = "IncludeOperatingDays"
            case useRealtimeData = "UseRealtimeData"
            case includePlacesContext = "IincludePlacesContext"
            case includeSituationsContext = "IncludeSituationsContext"
        }

        public init(modeFilter: ModeFilter? = nil,
                    lineFilter: LineDirectionFilter? = nil,
                    operatorFilter: OperatorFilter? = nil,
                    includeAllRestrictedLines: Bool? = true,
                    numberOfResults: Int?,
                    stopEventType: StopEventType?,
                    includePreviousCalls: Bool? = nil,
                    includeOnwardCalls: Bool? = nil,
                    includeOperatingDays: Bool? = nil,
                    useRealtimeData: UseRealtimeData? = .explanatory,
                    includePlacesContext: Bool? = false,
                    includeSituationsContext: Bool? = nil,
        ) {
            self.modeFilter = modeFilter
            self.lineFilter = lineFilter
            self.operatorFilter = operatorFilter
            self.includeAllRestrictedLines = includeAllRestrictedLines
            self.includeOnwardCalls = includeOnwardCalls
            self.includePreviousCalls = includePreviousCalls
            self.includeOperatingDays = includeOperatingDays
            self.useRealtimeData = useRealtimeData
            self.stopEventType = stopEventType
            self.includePlacesContext = includePlacesContext
            self.includeSituationsContext = includeSituationsContext
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
        /// This ID is only uniquie within ONE single StopEventRequest. Use a ID made by combining `service.journeyRef` and `thisCall.stopPoint.stopPointRef` in order to update a `StopEventResult`
        var id: String
        public let stopEvent: StopEvent

        public enum CodingKeys: String, CodingKey {
            case id = "Id"
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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OperatorFilterStructure)
    struct OperatorFilter: Codable, Sendable {
        public let operatorRef: String?
        public let exclude: Bool?

        public enum CodingKeys: String, CodingKey {
            case operatorRef = "OperatorRef"
            case exclude = "Exclude"
        }
    }


    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LineDirectionFilterStructure)
    struct LineDirectionFilter: Codable, Sendable {
        public let line: [LineRef]
        public let exclude: Bool?

        public enum CodingKeys: String, CodingKey {
            case line = "Line"
            case exclude = "Exclude"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__LineDirectionStructure)
    struct LineRef: Codable, Sendable {
        public let lineRef: String
        public let directionRef: String?

        public enum CodingKeys: String, CodingKey {
            case lineRef = "siri:LineRef"
            case directionRef = "siri:DirectionRef"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ModeFilterStructure)
    struct ModeFilter: Codable, Sendable {
        public let exclude: Bool?
        public let ptMode: [Mode.PtMode]?
        public let submodes: [PtModeChoice]?

        public enum CodingKeys: String, CodingKey {
            case exclude = "Exclude"
            case ptMode = "PtMode"
            case _0 = ""
        }

        public init(exclude: Bool?, ptMode: [Mode.PtMode]?, submodes: [PtModeChoice]? = nil) {
            self.exclude = exclude
            self.ptMode = ptMode
            self.submodes = submodes
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            exclude = try container.decode(Bool.self, forKey: .exclude)
            ptMode = try container.decode([Mode.PtMode]?.self, forKey: .ptMode)
            submodes = try container.decode([PtModeChoice]?.self, forKey: ._0)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(exclude, forKey: .exclude)
            try container.encodeIfPresent(ptMode, forKey: .ptMode)
            try container.encodeIfPresent(submodes, forKey: ._0)
        }
    }
}
