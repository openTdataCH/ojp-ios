//
//  OJPv2+LocationInformation.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

public extension OJPv2 {
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

    // TODO: where is that used?
    struct LocationInformationServiceDelivery: Codable {
        public let responseTimestamp: String
        public let producerRef: String
        public let locationInformationDelivery: LocationInformationDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case locationInformationDelivery = "OJPLocationInformationDelivery"
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
    }

    struct PlaceResult: Codable {
        public let place: Place
        public let complete: Bool
        public let probability: Float?

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    enum PlaceTypeChoice: Codable {
        case stopPlace(OJPv2.StopPlace)
        case address(OJPv2.Address)

        enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case address = "Address"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
                self = try .address(container.decode(Address.self, forKey: .address))
            } catch {
                self = try .stopPlace(container.decode(StopPlace.self, forKey: .stopPlace))
            }
        }

//        public init(from decoder: any Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            if container.contains(.stopPlace) {
//                self = try .stopPlace(
//                    container.decode(
//                        StopPlace.self,
//                        forKey: .stopPlace
//                    )
//                )
//            } else if container.contains(.address) {
//                self = try .address(
//                    container.decode(
//                        Address.self,
//                        forKey: .address
//                    )
//                )
//            } else {
//                throw OJPSDKError.notImplemented()
//            }
//        }
    }

    struct Place: Codable {
        public let place: PlaceTypeChoice

        public let name: InternationalText
        public let geoPosition: GeoPosition
        public let modes: [Mode]

        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case geoPosition = "GeoPosition"
            case modes = "Mode"
        }

        public init(from decoder: any Decoder) throws {
//            let singleValueContainer = try decoder.singleValueContainer()
//            self.place = try singleValueContainer.decode(OJPv2.PlaceTypeChoice.self)
            place = try PlaceTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(InternationalText.self, forKey: .name)
            geoPosition = try container.decode(GeoPosition.self, forKey: .geoPosition)
            modes = try container.decode([Mode].self, forKey: .modes)
        }
    }

    struct StopPlace: Codable {
        public let stopPlaceRef: String
        public let stopPlaceName: InternationalText
        public let privateCodes: [PrivateCode]
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCodes = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    struct Address: Codable {
        public let publicCode: String
        public let topographicPlaceRef: String?
        public let topographicPlaceName: String?
        public let countryName: String?
        public let postCode: String?
        public let name: InternationalText
        public let street: String?
        public let houseNumber: String?
        public let crossRoad: String?

        public enum CodingKeys: String, CodingKey {
            case publicCode = "PublicCode"
            case topographicPlaceName = "TopographicPlaceName"
            case topographicPlaceRef = "TopographicPlaceRef"
            case postCode = "PostCode"
            case name = "Name"
            case street = "Street"
            case houseNumber = "HouseNumber"
            case crossRoad = "CrossRoad"
            case countryName = "CountryName"
        }
    }

    struct PrivateCode: Codable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }

    struct LocationInformationRequest: Codable {
        public let requestTimestamp: Date
        public let initialInput: InitialInput
        public let restrictions: PlaceParam

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

    struct Rectangle: Codable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    struct PlaceParam: Codable {
        public init(type: [PlaceType], numberOfResults: Int = 10, includePtModes: Bool = true) {
            self.type = type
            self.numberOfResults = numberOfResults
            self.includePtModes = includePtModes
        }

        public let type: [PlaceType]
        public let numberOfResults: Int
        let includePtModes: Bool

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
        }
    }
}

extension OJPv2.PlaceTypeChoice: Identifiable {
    public var id: String {
        switch self {
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceRef
        case let .address(address):
            address.publicCode
        }
    }
}

extension OJPv2.PlaceResult: Identifiable {
    public var id: String { place.place.id }
}
