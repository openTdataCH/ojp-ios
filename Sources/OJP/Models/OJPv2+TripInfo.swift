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

        public enum CodingKeys: String, CodingKey {
            case journeyRef = "JourneyRef"
            case operatingDayRef = "OperatingDayRef"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripInfoParamStructure)
    struct TripInfoParam: Codable, Sendable {}

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
    struct TripInfoResult: Codable, Sendable {}
}
