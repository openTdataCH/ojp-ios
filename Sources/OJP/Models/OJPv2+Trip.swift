//
//  OJPv2+Trip.swift
//
//
//  Created by Terence Alberti on 06.05.2024.
//

import Foundation

public extension OJPv2 {
    struct TripDelivery: Codable {
        public let responseTimestamp: String
        public let requestMessageRef: String
        public let calcTime: Int?
        public let tripResults: [TripResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "ResponseTimestamp" // siri:
            case requestMessageRef = "RequestMessageRef" // siri:
            case calcTime = "CalcTime"
            case tripResults = "TripResult"
        }
    }

    struct TripResult: Codable {
        public let id: String
        public let tripType: TripTypeChoice
        public let tripFares: [TripFare]
        public let isAlternativeOption: Bool?

        public enum CodingKeys: String, CodingKey {
            case id = "Id"
            case tripFares = "TripFare"
            case isAlternativeOption = "IsAlternativeOption"
        }

        public init(from decoder: any Decoder) throws {
            tripType = try TripTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            id = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.id))
            tripFares = try container.decode([TripFare].self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.tripFares))
            isAlternativeOption = try? container.decode(Bool.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.isAlternativeOption))
        }

        public enum TripTypeChoice: Codable {
            case trip(OJPv2.Trip)
            case tripSummary(OJPv2.TripSummary)

            enum CodingKeys: String, CodingKey {
                case trip = "Trip"
                case tripSummary = "TripSummary"
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
                if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.trip)) {
                    self = try .trip(
                        container.decode(
                            Trip.self,
                            forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.trip)
                        )
                    )
                } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.tripSummary)) {
                    self = try .tripSummary(
                        container.decode(
                            TripSummary.self,
                            forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.tripSummary)
                        )
                    )
                } else {
                    throw OJPSDKError.notImplemented()
                }
            }
        }
    }

    struct Trip: Codable {
        public let id: String
        public let duration: String
        public let startTime: Date
        public let endTime: Date
        public let transfers: Int
        public let distance: Double?
        public let legs: [Leg]

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
            case startTime = "StartTime"
            case endTime = "EndTime"
            case transfers = "Transfers"
            case distance = "Distance"
            case legs = "Leg"
        }
    }

    struct Leg: Codable {
        public let id: Int
        public let duration: String?
        public let legType: LegTypeChoice

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
        }

        public init(from decoder: any Decoder) throws {
            legType = try LegTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            id = try container.decode(Int.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.id))
            duration = try? container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.duration))
        }

        public enum LegTypeChoice: Codable {
            case continous(OJPv2.ContinuousLeg)
            case timed(OJPv2.TimedLeg)
            case transfer(OJPv2.TransferLeg)

            enum CodingKeys: String, CodingKey {
                case continous = "ContinuousLeg"
                case timed = "TimedLeg"
                case transfer = "TransferLeg"
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
                if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.continous)) {
                    self = try .continous(
                        container.decode(
                            ContinuousLeg.self,
                            forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.continous)
                        )
                    )
                } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.timed)) {
                    self = try .timed(
                        container.decode(
                            TimedLeg.self,
                            forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.timed)
                        )
                    )
                } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.transfer)) {
                    self = try .transfer(
                        container.decode(
                            TransferLeg.self,
                            forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.transfer)
                        )
                    )
                } else {
                    throw OJPSDKError.notImplemented()
                }
            }
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TransferTypeEnumeration
    enum TransferType: String, Codable {
        case walk
        case shuttle
        case taxi
        case protectedConnection
        case guaranteedConnection
        case remainInVehicle
        case changeWithinVehicle
        case checkIn
        case checkOut
        case parkAndRide
        case bikeAndRide
        case carHire
        case bikeHire
        case other
    }

    // https://vdvde.github.io/OJP/develop/index.html#TransferLegStructure
    struct TransferLeg: Codable {
        public let transferTypes: [TransferType]
        public let legStart: LegStart
        public let legEnd: LegEnd
        public let duration: String
        
        enum CodingKeys: String, CodingKey {
            case transferTypes = "TransferType"
            case duration = "Duration"
            case legStart = "LegStart"
            case legEnd = "LegEnd"
        }
    }
    
    struct LegStart: Codable {
        public let stopPointRef: String
        public let name: InternationalText
        
        enum CodingKeys: String, CodingKey {
            case stopPointRef = "StopPointRef" // siri:
            case name = "Name"
        }
    }
    
    struct LegEnd: Codable {
        public let stopPointRef: String
        public let name: InternationalText
        
        enum CodingKeys: String, CodingKey {
            case stopPointRef = "StopPointRef" // siri:
            case name = "Name"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TimedLegStructure
    struct TimedLeg: Codable {
        public let legBoard: LegBoard
        public let legsIntermediate: [LegIntermediate]
        public let legAlight: LegAlight
        public let service: Service
        public let legTrack: LegTrack?

        enum CodingKeys: String, CodingKey {
            case legBoard = "LegBoard"
            case legsIntermediate = "LegIntermediate"
            case legAlight = "LegAlight"
            case service = "Service"
            case legTrack = "LegTrack"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ServiceArrivalStructure
    struct ServiceArrival: Codable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ServiceDepartureStructure
    struct ServiceDeparture: Codable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegBoardStructure
    struct LegBoard: Codable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival?
        public let serviceDeparture: ServiceDeparture

        // https://vdvde.github.io/OJP/develop/index.html#StopCallStatusGroup
        public let order: Int?
        public let requestStop: Bool?
        public let unplannedStop: Bool?
        public let notServicedStop: Bool?
        public let noBoardingAtStop: Bool?
        public let noAlightingAtStop: Bool?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "StopPointRef" // siri:
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case order = "Order"
            case requestStop = "RequestStop"
            case unplannedStop = "UnplannedStop"
            case notServicedStop = "NotServicedStop"
            case noBoardingAtStop = "NoBoardingAtStop"
            case noAlightingAtStop = "NoAlightingAtStop"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegIntermediateStructure
    struct LegIntermediate: Codable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuai: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival
        public let serviceDeparture: ServiceDeparture

        // https://vdvde.github.io/OJP/develop/index.html#StopCallStatusGroup
        public let order: Int?
        public let requestStop: Bool?
        public let unplannedStop: Bool?
        public let notServicedStop: Bool?
        public let noBoardingAtStop: Bool?
        public let noAlightingAtStop: Bool?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "StopPointRef" // siri:
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuai = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case order = "Order"
            case requestStop = "RequestStop"
            case unplannedStop = "UnplannedStop"
            case notServicedStop = "NotServicedStop"
            case noBoardingAtStop = "NoBoardingAtStop"
            case noAlightingAtStop = "NoAlightingAtStop"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegAlightStructure
    struct LegAlight: Codable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuai: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival
        public let serviceDeparture: ServiceDeparture?

        // https://vdvde.github.io/OJP/develop/index.html#StopCallStatusGroup
        public let order: Int?
        public let requestStop: Bool?
        public let unplannedStop: Bool?
        public let notServicedStop: Bool?
        public let noBoardingAtStop: Bool?
        public let noAlightingAtStop: Bool?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "StopPointRef" // siri:
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuai = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case order = "Order"
            case requestStop = "RequestStop"
            case unplannedStop = "UnplannedStop"
            case notServicedStop = "NotServicedStop"
            case noBoardingAtStop = "NoBoardingAtStop"
            case noAlightingAtStop = "NoAlightingAtStop"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ProductCategoryStructure
    struct ProductCategory: Codable {
        public let name: InternationalText?
        public let shortName: InternationalText?
        public let productCategoryRef: String?

        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case shortName = "ShortName"
            case productCategoryRef = "ProductCategoryRef"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#GeneralAttributeStructure
    struct Attribute: Codable {
        public let userText: InternationalText
        public let code: String

        public enum CodingKeys: String, CodingKey {
            case userText = "UserText"
            case code = "Code"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ContinuousServiceStructure
    struct Service: Codable {
        // https://vdvde.github.io/OJP/develop/index.html#ConventionalModesOfOperationEnumeration
        public let conventionalModeOfOperation: ConventionalModesOfOperation?

        public let operatingDayRef: String
        public let journeyRef: String
        public let publicCode: String?

        // siri:LineDirectionGroup
        public let lineRef: String
        public let directionRef: String?

        public let mode: Mode
        public let productCategory: ProductCategory?
        public let publishedServiceName: InternationalText? // TODO: https://github.com/openTdataCH/ojp-sdk/issues/23

        public let trainNumber: String?
        public let vehicleRef: String?
        public let attributes: [Attribute]
        public let operatorRef: String?

        public enum CodingKeys: String, CodingKey {
            case conventionalModeOfOperation = "ConventionalModeOfOperation"
            case operatingDayRef = "OperatingDayRef"
            case journeyRef = "JourneyRef"
            case publicCode = "PublicCode"
            case lineRef = "LineRef" // siri:
            case directionRef = "DirectionRef"
            case mode = "Mode"
            case productCategory = "ProductCategory"
            case publishedServiceName = "PublishedServiceName"
            case trainNumber = "TrainNumber"
            case vehicleRef = "siri:VehicleRef" // siri:
            case attributes = "Attribute"
            case operatorRef = "OperatorRef" // siri:
        }

        public enum ConventionalModesOfOperation: String, Codable {
            case scheduled
            case demandResponsive
            case flexibleRoute
            case flexibleArea
            case shuttle
            case pooling
            case replacement
            case school
            case pRM
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LinearShapeStructure
    struct LinearShape: Codable {
        // in XSD min 2 <GeoPosition> elements are required
        public let positions: [GeoPosition]

        public enum CodingKeys: String, CodingKey {
            case positions = "Position"
        }
    }

    // Variation of https://vdvde.github.io/OJP/develop/index.html#PlaceRefStructure
    // in the future we might get other elements, i.e. GeoPosition
    struct TrackSectionStopPlaceRef: Codable {
        public let stopPointRef: String
        public let stopPointName: InternationalText

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TrackSectionStructure
    struct TrackSection: Codable {
        public let trackSectionStart: TrackSectionStopPlaceRef?
        public let trackSectionEnd: TrackSectionStopPlaceRef?
        public let linkProjection: LinearShape?

        public enum CodingKeys: String, CodingKey {
            case trackSectionStart = "TrackSectionStart"
            case trackSectionEnd = "TrackSectionEnd"
            case linkProjection = "LinkProjection"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegTrackStructure
    struct LegTrack: Codable {
        public let trackSections: [TrackSection]

        public enum CodingKeys: String, CodingKey {
            case trackSections = "TrackSection"
        }
    }

    struct ContinuousLeg: Codable {}

    struct TripSummary: Codable {}

    struct TripFare: Codable {}

    struct TripRequest: Codable {
        public let requestTimestamp: Date

        public let origin: PlaceContext
        public let destination: PlaceContext
        public let via: [TripVia]?
        public let params: Params?

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case origin = "Origin"
            case destination = "Destination"
            case via = "Via"
            case params = "Params"
        }
    }

    struct PlaceContext: Codable {
        public let placeRef: PlaceRefChoice
        public let depArrTime: Date?

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
            case depArrTime = "DepArrTime"
        }
    }

    struct TripVia: Codable {
        public let viaPoint: PlaceRefChoice

        public enum CodingKeys: String, CodingKey {
            case viaPoint = "ViaPoint"
        }
    }

    enum PlaceRefChoice: Codable {
        case stopPlaceRef(String)
        case geoPosition(OJPv2.GeoPosition)

        enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case geoPosition = "siri:LocationStructure"
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .stopPlaceRef(stopPlace):
                try container.encode(stopPlace, forKey: CodingKeys.stopPlaceRef)
            case let .geoPosition(geoPosition):
                try container.encode(geoPosition, forKey: CodingKeys.geoPosition)
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.stopPlaceRef)) {
                self = try .stopPlaceRef(
                    container.decode(
                        String.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.stopPlaceRef)
                    )
                )
            } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.geoPosition)) {
                self = try .geoPosition(
                    container.decode(
                        GeoPosition.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.geoPosition)
                    )
                )
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    struct Params: Codable {

        public init(numberOfResultsBefore: Int? = nil, numberOfResultsAfter: Int? = nil, includeTrackSections: Bool? = nil, includeLegProjection: Bool? = nil, includeTurnDescription: Bool? = nil, includeIntermediateStops: Bool? = nil) {
            self.numberOfResultsBefore = numberOfResultsBefore
            self.numberOfResultsAfter = numberOfResultsAfter
            self.includeTrackSections = includeTrackSections
            self.includeLegProjection = includeLegProjection
            self.includeTurnDescription = includeTurnDescription
            self.includeIntermediateStops = includeIntermediateStops
        }
        
        let numberOfResultsBefore: Int?
        let numberOfResultsAfter: Int?
        let includeTrackSections: Bool?
        let includeLegProjection: Bool?
        let includeTurnDescription: Bool?
        let includeIntermediateStops: Bool?

        public enum CodingKeys: String, CodingKey {
            case numberOfResultsBefore = "NumberOfResultsBefore"
            case numberOfResultsAfter = "NumberOfResultsAfter"
            case includeTrackSections = "IncludeTrackSections"
            case includeLegProjection = "IncludeLegProjection"
            case includeTurnDescription = "IncludeTurnDescription"
            case includeIntermediateStops = "IncludeIntermediateStops"
        }
    }
}
