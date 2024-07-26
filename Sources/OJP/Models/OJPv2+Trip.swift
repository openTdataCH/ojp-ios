//
//  OJPv2+Trip.swift
//
//
//  Created by Terence Alberti on 06.05.2024.
//

import Duration
import Foundation
import XMLCoder

public extension OJPv2 {
    struct TripDelivery: Codable {
        public let responseTimestamp: String
        public let requestMessageRef: String
        public let calcTime: Int?
        public internal(set) var tripResults: [TripResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case calcTime = "CalcTime"
            case tripResults = "TripResult"
        }
    }

    struct TripResult: Codable, Identifiable {
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

            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            tripFares = try container.decode([TripFare].self, forKey: .tripFares)
            isAlternativeOption = try? container.decode(Bool.self, forKey: .isAlternativeOption)
        }

        public enum TripTypeChoice: Codable {
            case trip(OJPv2.Trip)
            case tripSummary(OJPv2.TripSummary)

            enum CodingKeys: String, CodingKey {
                case trip = "Trip"
                case tripSummary = "TripSummary"
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.trip) {
                    self = try .trip(
                        container.decode(
                            Trip.self,
                            forKey: .trip
                        )
                    )
                } else if container.contains(.tripSummary) {
                    self = try .tripSummary(
                        container.decode(
                            TripSummary.self,
                            forKey: .tripSummary
                        )
                    )
                } else {
                    throw OJPSDKError.notImplemented()
                }
            }
        }

        /// convenience property to access the underlying trip (as TripSummary is currently not supported)
        public var trip: Trip? {
            if case let .trip(trip) = tripType {
                return trip
            }
            return nil
        }
    }

    struct Trip: Codable, Identifiable {
        /// Unique within trip response. This ID must not be used over mutliple ``OJPv2/TripRequest``
        /// - Warning: This ID must not be used over mutliple ``OJPv2/TripRequest``. Use ``tripHash`` instead.
        public let id: String
        public let duration: Duration
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

        /// Trip hash similar to the implementation in the JS SDK.
        /// Can be used to de-duplicate trips in ``OJPv2/TripResult``
        public var tripHash: Int {
            var h = Hasher()

            for leg in legs {
                switch leg.legType {
                case let .continous(continuousLeg):
                    // TODO: Implement
                    h.combine("continuousLeg")
                case let .timed(timedLeg):
                    h.combine(timedLeg.service.publishedServiceName.text)
                    h.combine(timedLeg.legBoard.stopPointName.text)
                    h.combine(timedLeg.legBoard.serviceDeparture.timetabledTime)

                    h.combine(timedLeg.legAlight.serviceArrival.timetabledTime)
                    h.combine(timedLeg.legAlight.stopPointName.text)
                case let .transfer(transferLeg):
                    h.combine(transferLeg.transferTypes.hashValue)
                    h.combine(transferLeg.duration)
                }
            }
            return h.finalize()
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegStructure
    struct Leg: Codable, Identifiable {
        public let id: Int
        public let duration: Duration?
        public let legType: LegTypeChoice

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
        }

        public init(from decoder: any Decoder) throws {
            legType = try LegTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            duration = try? container.decode(Duration.self, forKey: .duration)
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
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.continous) {
                    self = try .continous(
                        container.decode(
                            ContinuousLeg.self,
                            forKey: .continous
                        )
                    )
                } else if container.contains(.timed) {
                    self = try .timed(
                        container.decode(
                            TimedLeg.self,
                            forKey: .timed
                        )
                    )
                } else if container.contains(.transfer) {
                    self = try .transfer(
                        container.decode(
                            TransferLeg.self,
                            forKey: .transfer
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
        public let legStart: PlaceRefChoice
        public let legEnd: PlaceRefChoice
        public let duration: Duration

        enum CodingKeys: String, CodingKey {
            case transferTypes = "TransferType"
            case duration = "Duration"
            case legStart = "LegStart"
            case legEnd = "LegEnd"
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
            case stopPointRef = "siri:StopPointRef"
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
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed
        public let serviceDeparture: ServiceDeparture? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed

        // https://vdvde.github.io/OJP/develop/index.html#StopCallStatusGroup
        public let order: Int?
        public let requestStop: Bool?
        public let unplannedStop: Bool?
        public let notServicedStop: Bool?
        public let noBoardingAtStop: Bool?
        public let noAlightingAtStop: Bool?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
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

    // https://vdvde.github.io/OJP/develop/index.html#LegAlightStructure
    struct LegAlight: Codable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
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
            case stopPointRef = "siri:StopPointRef"
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
        public let publishedServiceName: InternationalText

        public let trainNumber: String?
        public let vehicleRef: String?
        public let attributes: [Attribute]
        public let operatorRef: String?

        public let originText: InternationalText
        public let originStopPointRef: String?
        public let destinationText: InternationalText?
        public let destinationStopPointRef: String?

        public enum CodingKeys: String, CodingKey {
            case conventionalModeOfOperation = "ConventionalModeOfOperation"
            case operatingDayRef = "OperatingDayRef"
            case journeyRef = "JourneyRef"
            case publicCode = "PublicCode"
            case lineRef = "siri:LineRef"
            case directionRef = "DirectionRef"
            case mode = "Mode"
            case productCategory = "ProductCategory"
            case publishedServiceName = "PublishedServiceName"
            case trainNumber = "TrainNumber"
            case vehicleRef = "siri:VehicleRef"
            case attributes = "Attribute"
            case operatorRef = "siri:OperatorRef"
            case originText = "OriginText"
            case originStopPointRef = "OriginStopPointRef"
            case destinationText = "DestinationText"
            case destinationStopPointRef = "DestinationStopPointRef"
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

    // https://vdvde.github.io/OJP/develop/index.html#TrackSectionStructure
    struct TrackSection: Codable {
        public let trackSectionStart: PlaceRefChoice?
        public let trackSectionEnd: PlaceRefChoice?
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

    // https://vdvde.github.io/OJP/develop/index.html#ContinuousLegStructure
    struct ContinuousLeg: Codable {}

    struct TripSummary: Codable {}

    struct TripFare: Codable {}

    struct TripRequest: Codable {
        public let requestTimestamp: Date

        public let origin: PlaceContext
        public let destination: PlaceContext
        public let via: [TripVia]?
        public let params: TripParams?

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

    struct StopPlaceRef: Codable {
        let stopPlaceRef: String
        let name: InternationalText

        public init(stopPlaceRef: String, name: InternationalText) {
            self.stopPlaceRef = stopPlaceRef
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case name = "Name"
        }
    }

    struct StopPointRef: Codable {
        let stopPointRef: String
        let name: InternationalText

        public init(stopPointRef: String, name: InternationalText) {
            self.stopPointRef = stopPointRef
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case name = "Name"
        }
    }

    struct GeoPositionRef: Codable {
        let geoPosition: OJPv2.GeoPosition
        let name: InternationalText

        public init(geoPosition: OJPv2.GeoPosition, name: InternationalText) {
            self.geoPosition = geoPosition
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case geoPosition = "GeoPosition"
            case name = "Name"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#PlaceRefGroup
    enum PlaceRefChoice: Codable {
        case stopPlaceRef(StopPlaceRef)
        case geoPosition(GeoPositionRef)
        case stopPointRef(StopPointRef)

        enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPointRef = "siri:StopPointRef"
            case name = "Name"
        }

        public func encode(to encoder: Encoder) throws {
            var svc = encoder.singleValueContainer()
            switch self {
            case let .stopPlaceRef(stopPlaceRef):
                try svc.encode(stopPlaceRef)
            case let .stopPointRef(stopPointRef):
                try svc.encode(stopPointRef)
            case let .geoPosition(geoPositionRef):
                try svc.encode(geoPositionRef)
            }
        }

        public init(from decoder: any Decoder) throws {
            let svc = try decoder.singleValueContainer()

            if try decoder.container(keyedBy: StopPlaceRef.CodingKeys.self)
                .contains(.stopPlaceRef)
            {
                self = try .stopPlaceRef(
                    svc.decode(StopPlaceRef.self)
                )
                return
            } else if try decoder.container(keyedBy: StopPointRef.CodingKeys.self)
                .contains(.stopPointRef)
            {
                self = try .stopPointRef(
                    svc.decode(StopPointRef.self)
                )
            } else if try decoder.container(keyedBy: GeoPositionRef.CodingKeys.self)
                .contains(.geoPosition)
            {
                self = try .geoPosition(
                    svc.decode(GeoPositionRef.self)
                )
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ModeAndModeOfOperationFilterStructure
    struct ModeAndModeOfOperationFilter: Codable {
        public init(ptMode: [Mode.PtMode]?, exclude: Bool?) {
            self.ptMode = ptMode
            self.exclude = exclude
        }

        let ptMode: [Mode.PtMode]?
        let exclude: Bool?

        public enum CodingKeys: String, CodingKey {
            case exclude = "Exclude"
            case ptMode = "PtMode"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TripParamStructure
    struct TripParams: Codable {
        public init(
            numberOfResults: NumberOfResults = .minimum(10),
            includeTrackSections: Bool? = nil,
            includeLegProjection: Bool? = nil,
            includeTurnDescription: Bool? = nil,
            includeIntermediateStops: Bool? = nil,
            includeAllRestrictedLines: Bool? = nil,
            modeAndModeOfOperationFilter: ModeAndModeOfOperationFilter? = nil

        ) {
            switch numberOfResults {
            case let .before(numberOfResults):
                numberOfResultsBefore = numberOfResults
            case let .after(numberOfResults):
                numberOfResultsAfter = numberOfResults
            case let .minimum(count):
                _numberOfResults = count
            }

            self.includeTrackSections = includeTrackSections
            self.includeLegProjection = includeLegProjection
            self.includeTurnDescription = includeTurnDescription
            self.includeIntermediateStops = includeIntermediateStops
            self.includeAllRestrictedLines = includeAllRestrictedLines
            self.modeAndModeOfOperationFilter = modeAndModeOfOperationFilter
        }

        private var numberOfResultsBefore: Int? = nil
        private var numberOfResultsAfter: Int? = nil
        private var _numberOfResults: Int? = nil

        let includeTrackSections: Bool?
        let includeLegProjection: Bool?
        let includeTurnDescription: Bool?
        let includeIntermediateStops: Bool?
        let includeAllRestrictedLines: Bool?
        let modeAndModeOfOperationFilter: ModeAndModeOfOperationFilter?

        var numberOfResults: NumberOfResults {
            if let numberOfResultsBefore {
                return .before(numberOfResultsBefore)
            }
            if let numberOfResultsAfter {
                return .after(numberOfResultsAfter)
            }
            return .minimum(_numberOfResults ?? 10)
        }

        public enum CodingKeys: String, CodingKey {
            case numberOfResultsBefore = "NumberOfResultsBefore"
            case numberOfResultsAfter = "NumberOfResultsAfter"
            case _numberOfResults = "NumberOfResults"
            case includeTrackSections = "IncludeTrackSections"
            case includeLegProjection = "IncludeLegProjection"
            case includeTurnDescription = "IncludeTurnDescription"
            case includeIntermediateStops = "IncludeIntermediateStops"
            case includeAllRestrictedLines = "IncludeAllRestrictedLines"
            case modeAndModeOfOperationFilter = "ModeAndModeOfOperationFilter"
        }
    }

    /// Convenience enum to define [NumberOfResults](https://vdvde.github.io/OJP/develop/index.html#NumberOfResultsGroup)
    enum NumberOfResults: Codable {
        case before(Int)
        case after(Int)
        case minimum(Int)
    }
}
