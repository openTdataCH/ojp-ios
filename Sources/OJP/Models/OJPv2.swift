//
//  OJPv2.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

let OJP_SDK_Name = "IOS_SDK"
let OJP_SDK_Version = "0.0.1"

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
        let newKey = key.stringValue.replacingOccurrences(of: "siri:", with: "")
        return StrippedPrefixCodingKey(stringValue: newKey)!
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
        public let producerRef: String
        public let delivery: ServiceDeliveryType

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
        }

        public init(from decoder: any Decoder) throws {
            delivery = try ServiceDeliveryType(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            responseTimestamp = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.responseTimestamp))
            producerRef = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.producerRef))
        }
    }

    enum ServiceDeliveryType: Codable {
        case stopEvent(OJPv2.StopEventServiceDelivery)
        case locationInformation(OJPv2.LocationInformationDelivery)

        enum CodingKeys: String, CodingKey {
            case locationInformation = "OJPLocationInformationDelivery"
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
            } else {
                throw OJPError.notImplemented
            }
        }
    }

    struct StopEventServiceDelivery: Codable {
        let responseTimestamp: String
        let producerRef: String
        let stopEventDelivery: StopEventDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case stopEventDelivery = "OJPStopEventDelivery"
        }
    }

    struct StopEventDelivery: Codable {
        let places: [Place]
    }

    struct LocationInformationServiceDelivery: Codable {
        public let responseTimestamp: String
        public let producerRef: String
        public let locationInformationDelivery: LocationInformationDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case locationInformationDelivery = "OJPLocationInformationDelivery"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)

            responseTimestamp = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.responseTimestamp))
            producerRef = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.producerRef))
            locationInformationDelivery = try container.decode(OJPv2.LocationInformationDelivery.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.locationInformationDelivery))
        }
    }

    struct LocationInformationDelivery: Codable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let defaultLanguage: String?
        public let calcTime: Int?
        public let placeResults: [PlaceResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case defaultLanguage = "siri:DefaultLanguage"
            case calcTime = "CalcTime"
            case placeResults = "PlaceResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            responseTimestamp = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.responseTimestamp))
            requestMessageRef = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.requestMessageRef))
            defaultLanguage = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.defaultLanguage))
            calcTime = try container.decode(Int.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.calcTime))
            placeResults = try container.decode([OJPv2.PlaceResult].self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.placeResults))
        }
    }

    public struct PlaceResult: Codable {
        public let place: Place
        public let complete: Bool
        public let probability: Float?

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    public struct Place: Codable {
        public let stopPlace: StopPlace?
        public let name: Name
        public let geoPosition: GeoPosition
        public let mode: [Mode]

        public enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case name = "Name"
            case geoPosition = "GeoPosition"
            case mode = "Mode"
        }
    }

    public struct Mode: Codable {
        public let ptMode: String

        public enum CodingKeys: String, CodingKey {
            case ptMode = "PtMode"
        }
    }

    public struct StopPlace: Codable {
        public let stopPlaceRef: String
        public let stopPlaceName: Name
        public let privateCode: PrivateCode?
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCode = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    public struct Name: Codable {
        public let text: String

        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }

    public struct PrivateCode: Codable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
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
        public let requestTimestamp: String
        public let requestorRef: String
        public let locationInformationRequest: LocationInformationRequest

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case locationInformationRequest = "OJPLocationInformationRequest"
        }
    }

    struct LocationInformationRequest: Codable {
        public let requestTimestamp: String
        public let initialInput: InitialInput
        public let restrictions: Restrictions

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case initialInput = "InitialInput"
            case restrictions = "Restrictions"
        }
    }

    struct InitialInput: Codable {
        public let geoRestriction: GeoRestriction?
        public let name: String?

        public enum CodingKeys: String, CodingKey {
            case geoRestriction = "GeoRestriction"
            case name = "Name"
        }
    }

    struct GeoRestriction: Codable {
        public let rectangle: Rectangle?

        public enum CodingKeys: String, CodingKey {
            case rectangle = "Rectangle"
        }
    }

    public struct Rectangle: Codable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    public struct Restrictions: Codable {
        public let type: String
        public let numberOfResults: Int
        let includePtModes: Bool

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
        }
    }
}
