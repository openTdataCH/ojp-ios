//
//  OJPv2.swift
//
//
//  Created by Terence Alberti on 08.05.2024.
//

import Foundation

let OJP_SDK_Name = "IOS_SDK"


public struct OJPv2: Codable {
    let request: Request?
    let response: Response?

    enum CodingKeys: String, CodingKey {
        case request = "OJPRequest"
        case response = "OJPResponse"
    }

    public struct Response: Codable {
        public let serviceDelivery: ServiceDelivery

        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "siri:ServiceDelivery"
        }
    }

    public struct ServiceDelivery: Codable {
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
            producerRef = try? container.decode(String.self, forKey: .producerRef)
        }
    }

    public enum ServiceDeliveryTypeChoice: Codable {
        case stopEvent(OJPv2.StopEventServiceDelivery)
        case locationInformation(OJPv2.LocationInformationDelivery)
        case trip(OJPv2.TripDelivery)

        enum CodingKeys: String, CodingKey {
            case locationInformation = "OJPLocationInformationDelivery"
            case trip = "OJPTripDelivery"
            case stopEvent = "OJPStopEventRequest"
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
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    public struct Request: Codable {
        public let serviceRequest: ServiceRequest

        public enum CodingKeys: String, CodingKey {
            case serviceRequest = "siri:ServiceRequest"
        }
    }

    public struct ServiceRequest: Codable {
        public let requestTimestamp: Date
        public let requestorRef: String
        public let locationInformationRequest: LocationInformationRequest?
        public let tripRequest: TripRequest?

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case locationInformationRequest = "OJPLocationInformationRequest"
            case tripRequest = "OJPTripRequest"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#InternationalTextStructure
    public struct InternationalText: Codable {
        public let text: String

        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }

    // https://laidig.github.io/siri-20-java/doc/schemas/siri_location-v2_0_xsd/complexTypes/LocationStructure.html
    public struct GeoPosition: Codable {
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

    // https://vdvde.github.io/OJP/develop/index.html#ModeStructure
    public struct Mode: Codable {
        public let ptMode: PtMode

        // https://laidig.github.io/siri-20-java/doc/schemas/siri_modes-v1_1_xsd/schema-overview.html
        // siri:PtModeChoiceGroup
        // keep busSubmode, railSubmode for now
        public let busSubmode: String?
        // https://laidig.github.io/siri-20-java/doc/schemas/siri_modes-v1_1_xsd/elements/RailSubmode.html
        public let railSubmode: String?

        public let name: InternationalText?
        public let shortName: InternationalText?

        public enum CodingKeys: String, CodingKey {
            case ptMode = "PtMode"
            case busSubmode = "siri:BusSubmode"
            case railSubmode = "siri:RailSubmode"
            case name = "Name"
            case shortName = "ShortName"
        }

        public enum PtMode: String, Codable {
            case rail
            case bus
            case tram
            case water
            case telecabin
            case underground
            case unknown

            public init(from decoder: Decoder) throws {
                self = try PtMode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
            }
        }
    }
}
