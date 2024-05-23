//
//  OJPv2.swift
//
//
//  Created by Terence Alberti on 08.05.2024.
//

import Foundation

let OJP_SDK_Name = "IOS_SDK"
let OJP_SDK_Version = "0.0.4"

struct StrippedPrefixCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }

    static func stripPrefix(fromKey key: CodingKey) -> StrippedPrefixCodingKey {
        if let tail = key.stringValue.split(separator: ":").last {
            return StrippedPrefixCodingKey(stringValue: String(tail))!
        }
        return StrippedPrefixCodingKey(stringValue: key.stringValue)!
    }
}

public struct OJPv2: Codable {
    let request: Request?
    let response: Response?

    enum CodingKeys: String, CodingKey {
        case request = "OJPRequest"
        case response = "OJPResponse"
    }

    struct Response: Codable {
        public let serviceDelivery: ServiceDelivery

        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "siri:ServiceDelivery"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            serviceDelivery = try container.decode(OJPv2.ServiceDelivery.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.serviceDelivery))
        }
    }

    struct ServiceDelivery: Codable {
        public let responseTimestamp: String
        public let producerRef: String?
        public let delivery: ServiceDeliveryTypeChoice

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
        }

        public init(from decoder: any Decoder) throws {
            delivery = try ServiceDeliveryTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            responseTimestamp = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.responseTimestamp))
            producerRef = try? container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.producerRef))
        }
    }

    enum ServiceDeliveryTypeChoice: Codable {
        case stopEvent(OJPv2.StopEventServiceDelivery)
        case locationInformation(OJPv2.LocationInformationDelivery)
        case trip(OJPv2.TripDelivery)

        enum CodingKeys: String, CodingKey {
            case locationInformation = "OJPLocationInformationDelivery"
            case trip = "OJPTripDelivery"
            case stopEvent = "OJPStopEventRequest"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.locationInformation)) {
                self = try .locationInformation(
                    container.decode(
                        LocationInformationDelivery.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.locationInformation)
                    )
                )
            } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.trip)) {
                self = try .trip(
                    container.decode(
                        TripDelivery.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.trip)
                    )
                )
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

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

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)

            longitude = try container.decode(Double.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.longitude))
            latitude = try container.decode(Double.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.latitude))
        }
    }

    struct Request: Codable {
        public let serviceRequest: ServiceRequest

        public enum CodingKeys: String, CodingKey {
            case serviceRequest = "siri:ServiceRequest"
        }
    }

    struct ServiceRequest: Codable {
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
}
