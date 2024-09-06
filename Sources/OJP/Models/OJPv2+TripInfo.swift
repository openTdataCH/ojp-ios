//
//  OJPv2+TripInfo.swift
//
//
//  Created by Lehnherr Reto on 05.09.2024.
//

import Duration
import Foundation
import XMLCoder

public extension OJPv2 {
    struct TripInfoRequest: Codable, Sendable {
        let journeyRef: String
        let operatingDayRef: String // ???
        let params: TripInfoParam

        public enum CodingKeys: String, CodingKey {
            case journeyRef = "JourneyRef"
            case operatingDayRef = "OperatingDayRef"
            case params = "Params"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripInfoParamStructure)
    struct TripInfoParam: Codable, Sendable {
        let useRealTimeData: UseRealtimeData?
        let includeCalls: Bool
        let includePosition: Bool
        let includeService: Bool
        let includeTrackSections: Bool
        let includeTrackProjection: Bool
        let includePlacesContext: Bool

        public init(useRealTimeData: OJPv2.UseRealtimeData? = nil, includeCalls: Bool = true, includePosition: Bool = true, includeService: Bool = true, includeTrackSections: Bool = true, includeTrackProjection: Bool = false, includePlacesContext: Bool = true) {
            self.useRealTimeData = useRealTimeData
            self.includeCalls = includeCalls
            self.includePosition = includePosition
            self.includeService = includeService
            self.includeTrackSections = includeTrackSections
            self.includeTrackProjection = includeTrackProjection
            self.includePlacesContext = includePlacesContext
        }

        public enum CodingKeys: String, CodingKey {
            case useRealTimeData = "UseRealTimeData"
            case includeCalls = "IncludeCalls"
            case includePosition = "IncludePosition"
            case includeService = "IncludeService"
            case includeTrackSections = "IncludeTrackSections"
            case includeTrackProjection = "IncludeTrackProjection"
            case includePlacesContext = "IncludePlacesContext"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPTripInfoDeliveryStructure)
    struct TripInfoDelivery: Codable, Sendable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let calcTime: Int?
        public let tripInfoResponseContext: TripResponseContext?
        public internal(set) var tripInfoResults: [TripInfoResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case calcTime = "CalcTime"
            case tripInfoResponseContext = "TripInfoResponseContext"
            case tripInfoResults = "TripInfoResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            responseTimestamp = try container.decode(String.self, forKey: .responseTimestamp)
            requestMessageRef = try container.decodeIfPresent(String.self, forKey: .requestMessageRef)
            calcTime = try container.decodeIfPresent(Int.self, forKey: .calcTime)
            tripInfoResponseContext = try container.decodeIfPresent(OJPv2.TripResponseContext.self, forKey: .tripInfoResponseContext)
            tripInfoResults = try (container.decodeIfPresent([OJPv2.TripInfoResult].self, forKey: .tripInfoResults)) ?? [] // tripInfoResults could be optional
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripInfoResultStructure)
    struct TripInfoResult: Codable, Sendable {
        public let previousCalls: [StopCallStatus]?
        public let onwardCalls: [StopCallStatus]?
        public let service: DatedJourney?

        public enum CodingKeys: String, CodingKey {
            case previousCalls = "PreviousCall"
            case onwardCalls = "OnwardCall"
            case service = "Service"
        }
    }
}
