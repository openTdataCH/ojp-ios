//
//  OJPv2+LocationInformation.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

public extension OJPv2 {
    struct LocationInformationDelivery: Codable, Sendable {
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

    struct PlaceResult: Codable, Sendable, Hashable {
        public let place: Place
        public let complete: Bool
        public let probability: Float?

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    enum PlaceTypeChoice: Codable, Sendable, Hashable {
        case stopPoint(OJPv2.StopPoint)
        case stopPlace(OJPv2.StopPlace)
        case address(OJPv2.Address)
        case topographicPlace(OJPv2.TopographicPlace)
        case pointOfInterest(OJPv2.PointOfInterest)

        enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case address = "Address"
            case stopPoint = "StopPoint"
            case topographicPlace = "TopographicPlace"
            case pointOfInterest = "PointOfInterest"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.stopPlace) {
                self = try .stopPlace(container.decode(StopPlace.self, forKey: .stopPlace))
            } else if container.contains(.stopPoint) {
                self = try .stopPoint(container.decode(StopPoint.self, forKey: .stopPoint))
            } else if container.contains(.topographicPlace) {
                self = try .topographicPlace(container.decode(TopographicPlace.self, forKey: .topographicPlace))
            } else if container.contains(.address) {
                self = try .address(container.decode(Address.self, forKey: .address))
            } else {
                self = try .pointOfInterest(container.decode(PointOfInterest.self, forKey: .pointOfInterest))
            }
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__PlaceStructure)
    struct Place: Codable, Sendable, Hashable {
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
            place = try PlaceTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(InternationalText.self, forKey: .name)
            geoPosition = try container.decode(GeoPosition.self, forKey: .geoPosition)
            modes = try container.decode([Mode].self, forKey: .modes)
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TopographicPlaceStructure)
    struct TopographicPlace: Codable, Sendable, Hashable {
        public let topographicPlaceCode: String
        public let topographicPlaceName: InternationalText

        public enum CodingKeys: String, CodingKey {
            case topographicPlaceCode = "TopographicPlaceCode"
            case topographicPlaceName = "TopographicPlaceName"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__PointOfInterestStructure)
    struct PointOfInterest: Codable, Sendable, Hashable {

        public let publicCode: String
        public let name: InternationalText
        public let nameSuffix: InternationalText?

        public let pointOfInterestCategory: [PointOfInterestCategory]?
        internal let _poiAdditionalInformation: PointOfInterestAdditionalInformation?

        /// Note: this is a convenience dictionary for the  ``OJPv2/PointOfInterestAdditionalInformation`
        public let poiAdditionalInformation: [String: String]?


        public enum CodingKeys: String, CodingKey {
            case publicCode = "PublicCode"
            case name = "Name"
            case nameSuffix = "NameSuffix"
            case pointOfInterestCategory = "PointOfInterestCategory"
            case _poiAdditionalInformation = "POIAdditionalInformation"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.publicCode = try container.decode(String.self, forKey: .publicCode)
            self.name = try container.decode(InternationalText.self, forKey: .name)
            self.nameSuffix = try container.decode(InternationalText?.self, forKey: .nameSuffix)
            self.pointOfInterestCategory = try container.decodeIfPresent([PointOfInterestCategory].self, forKey: .pointOfInterestCategory)
            self._poiAdditionalInformation = try container.decodeIfPresent(PointOfInterestAdditionalInformation.self, forKey: ._poiAdditionalInformation)
            self.poiAdditionalInformation = _poiAdditionalInformation?.poiAdditionalInformation.reduce(into: [:], { partialResult, keyValue in
                partialResult[keyValue.key] = keyValue.value
            })
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__PointOfInterestAdditionalInformationStructure)
    struct PointOfInterestAdditionalInformation: Codable, Sendable, Hashable {
        internal let poiAdditionalInformation: [CategoryKeyValue]

        public enum CodingKeys: String, CodingKey {
            case poiAdditionalInformation = "POIAdditionalInformation"
        }
    }


    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__CategoryKeyValueType)
    struct CategoryKeyValue: Codable, Sendable, Hashable {
        public let key: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case key = "Key"
            case value = "Value"
        }
    }


    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__PointOfInterestFilterStructure)
    struct PointOfInterestFilter: Codable, Sendable {
        /// Whether categories in list are to include or exclude from search. Default is FALSE.
        public let exclude: Bool?
        /// These POI categories can be used to filter POIs. If more than one is given the filtering is by logical "OR" (when Exclude=FALSE) and logical "AND" (when Exclude=TRUE).
        public let pointOfInterestCategory: [PointOfInterestCategory]?

        public init(exclude: Bool? = false, pointOfInterestCategory: [PointOfInterestCategory]) {
            self.exclude = exclude
            self.pointOfInterestCategory = pointOfInterestCategory
        }

        public enum CodingKeys: String, CodingKey {
            case exclude = "Exclude"
            case pointOfInterestCategory = "PointOfInterestCategory"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__PointOfInterestCategoryStructure)
    enum PointOfInterestCategory: Codable, Sendable, Hashable {
        case osmTag(OSMTag)
        case pointOfInterestClassification(String)

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.osmTag) {
                self = try .osmTag(container.decode(OSMTag.self, forKey: .osmTag))
            } else {
                self = try .pointOfInterestClassification(container.decode(String.self, forKey: .pointOfInterestClassification))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var svc = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .osmTag(osmTag):
                try svc.encode(osmTag, forKey: .osmTag)
            case let .pointOfInterestClassification(string):
                try svc.encode(string, forKey: .pointOfInterestClassification)
            }
        }

        public enum CodingKeys: String, CodingKey {
            case osmTag = "OsmTag"
            case pointOfInterestClassification = "PointOfInterestClassification"
        }

        /// convenience property
        public var value: String {
            switch self {
            case .osmTag(let osmTag):
                osmTag.value
            case .pointOfInterestClassification(let value):
                value
            }
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/release/2.0/documentation-tables/ojp.html#type_ojp__OsmTagStructure)
    struct OSMTag: Codable, Sendable, Hashable {
        /// For Sharing POIs, this vill always be "amenity"
        public let tag: String
        public let value: String

        public init(tag: String = "amenity", value: String) {
            self.tag = tag
            self.value = value
        }

        public enum CodingKeys: String, CodingKey {
            case tag = "Tag"
            case value = "Value"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopPointStructure)
    struct StopPoint: Codable, Sendable, Hashable {
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let parentRef: String?
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case parentRef = "ParentRef"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    struct StopPlace: Codable, Sendable, Hashable {
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

    struct Address: Codable, Sendable, Hashable {
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

    struct PrivateCode: Codable, Sendable, Hashable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }

    enum LocationInformationInputTypeChoice: Codable, Sendable {
        case initialInput(InitialInput)
        case placeRef(PlaceRefChoice)

        public enum CodingKeys: String, CodingKey {
            case initialInput = "InitialInput"
            case placeRef = "PlaceRef"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if container.contains(.initialInput) {
                let initial = try container.decode(InitialInput.self, forKey: .initialInput)
                self = .initialInput(initial)
            } else if container.contains(.placeRef) {
                let placeRef = try PlaceRefChoice(from: decoder)
                self = .placeRef(placeRef)
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    struct LocationInformationRequest: Codable, Sendable {
        public let requestTimestamp: Date
        public let input: LocationInformationInputTypeChoice
        public let restrictions: PlaceParam

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case restrictions = "Restrictions"

            case initialInput = "InitialInput"
            case placeRef = "PlaceRef"
        }

        public init(requestTimestamp: Date, input: LocationInformationInputTypeChoice, restrictions: PlaceParam) {
            self.requestTimestamp = requestTimestamp
            self.input = input
            self.restrictions = restrictions
        }

        public init(from decoder: any Decoder) throws {
            input = try LocationInformationInputTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            requestTimestamp = try container.decode(Date.self, forKey: .requestTimestamp)
            restrictions = try container.decode(PlaceParam.self, forKey: .restrictions)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: OJPv2.LocationInformationRequest.CodingKeys.self)
            try container.encode(requestTimestamp, forKey: OJPv2.LocationInformationRequest.CodingKeys.requestTimestamp)
            switch input {
            case let .initialInput(initialInput):
                try container.encode(initialInput, forKey: .initialInput)
            case let .placeRef(placeRefChoice):
                try container.encode(placeRefChoice, forKey: .placeRef)
            }
            // Order of encoded elements is enforced by service. would fail otherwise
            try container.encode(restrictions, forKey: OJPv2.LocationInformationRequest.CodingKeys.restrictions)
        }
    }

    struct InitialInput: Codable, Sendable {
        public let geoRestriction: GeoRestriction?
        public let name: String?

        public enum CodingKeys: String, CodingKey {
            case geoRestriction = "GeoRestriction"
            case name = "Name"
        }
    }

    struct GeoRestriction: Codable, Sendable {
        public let rectangle: Rectangle?

        public enum CodingKeys: String, CodingKey {
            case rectangle = "Rectangle"
        }
    }

    struct Rectangle: Codable, Sendable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public init(upperLeft: GeoPosition, lowerRight: GeoPosition) {
            self.upperLeft = upperLeft
            self.lowerRight = lowerRight
        }

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    struct PlaceParam: Codable, Sendable {
        public init(type: [PlaceType], numberOfResults: Int = 10, includePtModes: Bool = true, modeFilter: ModeFilter? = nil, pointOfInterestFilter: PointOfInterestFilter? = nil) {
            self.type = type
            self.numberOfResults = numberOfResults
            self.includePtModes = includePtModes
            self.modes = modeFilter
            self.pointOfInterestFilter = pointOfInterestFilter
        }

        public let type: [PlaceType]
        public let numberOfResults: Int
        let includePtModes: Bool
        public let modes: ModeFilter?
        public let pointOfInterestFilter: PointOfInterestFilter?

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
            case modes = "Modes"
            case pointOfInterestFilter = "PointOfInterestFilter"
        }
    }
}

extension OJPv2.PlaceTypeChoice: Identifiable {
    public var id: String {
        switch self {
        case let .stopPoint(stopPoint):
            stopPoint.stopPointRef
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceRef
        case let .address(address):
            address.publicCode
        case let .topographicPlace(topographicPlace):
            topographicPlace.topographicPlaceCode
        case let .pointOfInterest(pointOfInterest):
            pointOfInterest.publicCode
        }
    }
}

extension OJPv2.PlaceResult: Identifiable {
    public var id: String { place.place.id }
}
