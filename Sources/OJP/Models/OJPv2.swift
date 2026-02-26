//
//  OJPv2.swift
//
//
//  Created by Terence Alberti on 08.05.2024.
//

import Foundation

let OJP_SDK_Name = "IOS_SDK"

public struct OJPv2: Codable, Sendable {
    let request: Request?
    let response: Response?

    enum CodingKeys: String, CodingKey {
        case request = "OJPRequest"
        case response = "OJPResponse"
    }

    public struct Response: Codable, Sendable {
        public let serviceDelivery: ServiceDelivery

        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "siri:ServiceDelivery"
        }
    }

    public struct ServiceDelivery: Codable, Sendable {
        public let responseTimestamp: String
        public let producerRef: String?
        public let delivery: ServiceDeliveryTypeChoice

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
        }

        public init(from decoder: any Decoder) throws {
            delivery = try ServiceDeliveryTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            responseTimestamp = try container.decode(String.self, forKey: .responseTimestamp)
            producerRef = try container.decodeIfPresent(String.self, forKey: .producerRef)
        }
    }

    public enum ServiceDeliveryTypeChoice: Codable, Sendable {
        case stopEvent(OJPv2.StopEventDelivery)
        case locationInformation(OJPv2.LocationInformationDelivery)
        case trip(OJPv2.TripDelivery)
        case tripInfo(OJPv2.TripInfoDelivery)
        case tripRefinement(OJPv2.TripRefineDelivery)

        enum CodingKeys: String, CodingKey {
            case locationInformation = "OJPLocationInformationDelivery"
            case trip = "OJPTripDelivery"
            case tripInfo = "OJPTripInfoDelivery"
            case stopEvent = "OJPStopEventDelivery"
            case tripRefinement = "OJPTripRefineDelivery"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.locationInformation) {
                self = try .locationInformation(
                    container.decode(
                        LocationInformationDelivery.self,
                        forKey: .locationInformation
                    )
                )
            } else if container.contains(.trip) {
                self = try .trip(
                    container.decode(
                        TripDelivery.self,
                        forKey: .trip
                    )
                )
            } else if container.contains(.tripInfo) {
                self = try .tripInfo(
                    container.decode(
                        TripInfoDelivery.self,
                        forKey: .tripInfo
                    )
                )
            } else if container.contains(.tripRefinement) {
                self = try .tripRefinement(
                    container.decode(
                        TripRefineDelivery.self,
                        forKey: .tripRefinement
                    )
                )
            } else if container.contains(.stopEvent) {
                self = try .stopEvent(
                    container.decode(
                        StopEventDelivery.self,
                        forKey: .stopEvent
                    )
                )
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    public struct Request: Codable, Sendable {
        public let serviceRequest: ServiceRequest

        public enum CodingKeys: String, CodingKey {
            case serviceRequest = "siri:ServiceRequest"
        }
    }

    public struct ServiceRequest: Codable, Sendable {
        init(
            requestContext: OJPv2.ServiceRequestContext,
            requestTimestamp: Date,
            requestorRef: String,
            locationInformationRequest: OJPv2.LocationInformationRequest? = nil,
            tripRequest: OJPv2.TripRequest? = nil,
            tripInfoRequest: OJPv2.TripInfoRequest? = nil,
            stopEventRequest: OJPv2.StopEventRequest? = nil,
            tripRefineRequest: OJPv2.TripRefineRequest? = nil
        ) {
            self.requestContext = requestContext
            self.requestTimestamp = requestTimestamp
            self.requestorRef = requestorRef
            self.locationInformationRequest = locationInformationRequest
            self.tripRequest = tripRequest
            self.tripInfoRequest = tripInfoRequest
            self.stopEventRequest = stopEventRequest
            self.tripRefineRequest = tripRefineRequest
        }

        public let requestContext: ServiceRequestContext
        public let requestTimestamp: Date
        public let requestorRef: String
        public let locationInformationRequest: LocationInformationRequest?
        public let tripRequest: TripRequest?
        public let tripInfoRequest: TripInfoRequest?
        public let stopEventRequest: StopEventRequest?
        public let tripRefineRequest: OJPv2.TripRefineRequest?

        public enum CodingKeys: String, CodingKey {
            case requestContext = "siri:ServiceRequestContext"
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case locationInformationRequest = "OJPLocationInformationRequest"
            case tripRequest = "OJPTripRequest"
            case tripInfoRequest = "OJPTripInfoRequest"
            case stopEventRequest = "OJPStopEventRequest"
            case tripRefineRequest = "OJPTripRefineRequest"
        }
    }

    public struct ServiceRequestContext: Codable, Sendable {
        public let language: String

        public enum CodingKeys: String, CodingKey {
            case language = "siri:Language"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__InternationalTextStructure
    public struct InternationalText: Codable, Sendable, Hashable {
        public let text: String

        public init(_ text: String = "") {
            self.text = text
        }

        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__LocationStructure
    public struct GeoPosition: Codable, Sendable, Hashable {
        public let longitude: Double
        public let latitude: Double

        public enum CodingKeys: String, CodingKey {
            case longitude = "siri:Longitude"
            case latitude = "siri:Latitude"
        }

        public init(longitude: Double, latitude: Double) {
            self.longitude = longitude
            self.latitude = latitude
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#group_siri__PtModeChoiceGroup)
    /// Used to specify submodes
    public enum PtModeChoice: Codable, Sendable, Hashable {
        case railSubmode(RailSubmode)
        case telecabinSubmode(TelecabinSubmode)
        case busSubmode(String)
        case funicularSubmode(String)
        case waterSubmode(String)
        case tramSubmode(String)

        public enum CodingKeys: String, CodingKey {
            case railSubmode = "siri:RailSubmode"
            case telecabinSubmode = "siri:TelecabinSubmode"
            case busSubmode = "siri:BusSubmode"
            case funicularSubmode = "siri:FunicularSubmode"
            case waterSubmode = "siri:WaterSubmode"
            case tramSubmode = "siri:TramSubmode"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.busSubmode) {
                self = .busSubmode(try container.decode(String.self, forKey: .busSubmode))
            } else if container.contains(.railSubmode) {
                self = .railSubmode(try container.decode(RailSubmode.self, forKey: .railSubmode))
            } else if container.contains(.telecabinSubmode) {
                self = .telecabinSubmode(try container.decode(TelecabinSubmode.self, forKey: .telecabinSubmode))
            } else if container.contains(.funicularSubmode) {
                self = .funicularSubmode(try container.decode(String.self, forKey: .funicularSubmode))
            } else if container.contains(.waterSubmode) {
                self = .waterSubmode(try container.decode(String.self, forKey: .waterSubmode))
            } else if container.contains(.tramSubmode) {
                self = .tramSubmode(try container.decode(String.self, forKey: .tramSubmode))
            } else {
                throw OJPSDKError.notImplemented()
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .railSubmode(let railSubmode):
                try container.encode(railSubmode, forKey: .railSubmode)
            case .telecabinSubmode(let telecabinSubmode):
                try container.encode(telecabinSubmode, forKey: .telecabinSubmode)
            case .busSubmode(let string):
                try container.encode(string, forKey: .busSubmode)
            case .funicularSubmode(let string):
                try container.encode(string, forKey: .busSubmode)
            case .waterSubmode(let string):
                try container.encode(string, forKey: .waterSubmode)
            case .tramSubmode(let string):
                try container.encode(string, forKey: .tramSubmode)
            }
        }

//        public func encode(to encoder: any Encoder) throws {
//            var svc = encoder.singleValueContainer()
//            switch self {
//            case let .railSubmode(railSubmode):
//                try svc.encode(railSubmode)
//            case let .telecabinSubmode(telecabinSubmode):
//                try svc.encode(telecabinSubmode)
//            }
//        }
    }

    public enum RailSubmode: String, Codable, Sendable {
        case unknown
        /// ICE, TGV, EC, RJX, NJ, EN
        case international
        /// IC
        case highSpeedRail
        ///  IR, IRN, IRE
        case interregionalRail
        ///  ATZ, PE
        case railShuttle
        ///  S, SN, RB, RE,
        case local

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }

    public enum TelecabinSubmode: String, Codable, Sendable {
        case funicular
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ModeStructure
    public struct Mode: Codable, Sendable, Hashable {
        public let ptMode: PtMode

        public init(ptMode: PtMode, submode: PtModeChoice? = nil, name: InternationalText? = nil, shortName: InternationalText?) {
            self.ptMode = ptMode
            self.submode = submode
            self.name = name
            self.shortName = shortName
        }

        // https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__ModeGroup
        // siri:PtModeChoiceGroup
         public let submode: PtModeChoice?

        public let name: InternationalText?
        public let shortName: InternationalText?

        public enum CodingKeys: String, CodingKey {
            case ptMode = "PtMode"
            case _0 = ""
            case name = "Name"
            case shortName = "ShortName"
        }

        public init(from decoder: any Decoder) throws {
            submode = try? PtModeChoice(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            ptMode = try container.decode(PtMode.self, forKey: .ptMode)
            name = try? container.decode(InternationalText.self, forKey: .name)
            shortName = try? container.decode(InternationalText.self, forKey: .ptMode)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(ptMode, forKey: .ptMode)
            try container.encode(submode, forKey: ._0)
            try container.encode(name, forKey: .name)
            try container.encode(shortName, forKey: .shortName)
        }
        
        public enum PtMode: String, Codable, Sendable {
            case air
            case bus
            case coach
            case ferry
            case metro
            case rail
            case trolleyBus
            case tram
            case water
            case cableway
            case telecabin
            case underground
            case taxi
            case funicular
            case lift
            case snowAndIce
            case unknown

            public init(from decoder: Decoder) throws {
                self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
            }
        }
    }
}
