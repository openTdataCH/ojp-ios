//
//  OJPv2+Trip.swift
//
//
//  Created by Terence Alberti on 06.05.2024.
//

import Duration
import Foundation
import XMLCoder

// TODO: can be removed as soon as Duration conforms to Sendable
#if swift(>=6.0)
    extension Duration: @unchecked @retroactive Sendable {}
#else
    extension Duration: @unchecked Sendable {}
#endif

// TODO: can be removed as soon as XMLCoder conforms to Sendable
#if swift(>=6.0)
    extension XMLEncoder.OutputFormatting: @unchecked @retroactive Sendable {}
#else
    extension XMLEncoder.OutputFormatting: @unchecked Sendable {}
#endif

public extension OJPv2 {
    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPTripDeliveryStructure)
    struct TripDelivery: Codable, Sendable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let calcTime: Int?
        public let tripResponseContext: ResponseContext?
        public internal(set) var tripResults: [TripResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case calcTime = "CalcTime"
            case tripResponseContext = "TripResponseContext"
            case tripResults = "TripResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            responseTimestamp = try container.decode(String.self, forKey: .responseTimestamp)
            requestMessageRef = try container.decodeIfPresent(String.self, forKey: .requestMessageRef)
            calcTime = try container.decodeIfPresent(Int.self, forKey: .calcTime)
            tripResponseContext = try container.decodeIfPresent(OJPv2.ResponseContext.self, forKey: .tripResponseContext)
            tripResults = try (container.decodeIfPresent([OJPv2.TripResult].self, forKey: .tripResults)) ?? [] // tripResults could be optional
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ResponseContextStructure)
    struct ResponseContext: Codable, Sendable {
        public let situations: Situation?
        public let places: [Place]

        public enum CodingKeys: String, CodingKey {
            case situations = "Situations"
            case places = "Places"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            situations = try container.decodeIfPresent(OJPv2.Situation.self, forKey: OJPv2.ResponseContext.CodingKeys.situations)
            do {
                places = try container.decode(Places.self, forKey: OJPv2.ResponseContext.CodingKeys.places).places
            } catch {
                debugPrint(error)
                places = []
            }
        }

        struct Places: Codable, Sendable {
            fileprivate let places: [Place]
            fileprivate enum CodingKeys: String, CodingKey {
                case places = "Place"
            }
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__SituationsStructure
    struct Situation: Codable, Sendable {
        public let ptSituations: [PTSituation]?
        public let roadSituations: [RoadSituation]?

        enum CodingKeys: String, CodingKey {
            case ptSituations = "PtSituation"
            case roadSituations = "RoadSituation"
        }
    }

    struct SummaryContent: Codable, Sendable {
        public let summaryText: String

        public enum CodingKeys: String, CodingKey {
            case summaryText = "siri:SummaryText"
        }
    }

    struct ReasonContent: Codable, Sendable {
        public let reasonText: String

        public enum CodingKeys: String, CodingKey {
            case reasonText = "siri:ReasonText"
        }
    }

    struct DescriptionContent: Codable, Sendable {
        public let descriptionText: String

        public enum CodingKeys: String, CodingKey {
            case descriptionText = "siri:DescriptionText"
        }
    }

    struct ConsequenceContent: Codable, Sendable {
        public let consequenceText: String

        public enum CodingKeys: String, CodingKey {
            case consequenceText = "siri:ConsequenceText"
        }
    }

    struct RecommendationContent: Codable, Sendable {
        public let recommendationText: String

        public enum CodingKeys: String, CodingKey {
            case recommendationText = "siri:RecommendationText"
        }
    }

    struct RemarkContent: Codable, Sendable {
        public let remarkText: String

        public enum CodingKeys: String, CodingKey {
            case remarkText = "siri:Remark"
        }
    }

    struct DurationContent: Codable, Sendable {
        public let durationText: String

        public enum CodingKeys: String, CodingKey {
            case durationText = "siri:DurationText"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__InfoLinkStructure
    struct InfoLink: Codable, Sendable, Identifiable {
        public let url: URL
        /// if a `label` is present, display that instead of the url. It will contain a url escaped `<a>` tag.
        public let label: String?

        public var id: String { url.absoluteString + (label ?? "") }

        public enum CodingKeys: String, CodingKey {
            case url = "siri:Uri"
            case label = "siri:Label"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            url = try container.decode(URL.self, forKey: .url)
            label = try container.decodeIfPresent(String.self, forKey: .label)?
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__TextualContentStructure
    struct TextualContent: Codable, Sendable {
        public let summaryContent: SummaryContent
        public let reasonContent: ReasonContent?
        public let descriptionContents: [DescriptionContent]
        public let consequenceContents: [ConsequenceContent]
        public let recommendationContents: [RecommendationContent]
        public let durationContent: DurationContent?
        public let remarkContents: [RemarkContent]
        public let infoLinks: [InfoLink]

        public enum CodingKeys: String, CodingKey {
            case summaryContent = "siri:SummaryContent"
            case reasonContent = "siri:ReasonContent"
            case descriptionContents = "siri:DescriptionContent"
            case consequenceContents = "siri:ConsequenceContent"
            case recommendationContents = "siri:RecommendationContent"
            case durationContent = "siri:DurationContent"
            case remarkContents = "siri:RemarkContent"
            case infoLinks = "siri:InfoLink"
        }

        public init(from decoder: any Decoder) throws {
            // optionals for arrays to avoid this bug: https://github.com/CoreOffice/XMLCoder/issues/283
            let container = try decoder.container(keyedBy: CodingKeys.self)
            summaryContent = try container.decode(OJPv2.SummaryContent.self, forKey: CodingKeys.summaryContent)
            reasonContent = (try? container.decodeIfPresent(OJPv2.ReasonContent.self, forKey: CodingKeys.reasonContent)) ?? nil
            descriptionContents = (try? container.decode([OJPv2.DescriptionContent].self, forKey: OJPv2.TextualContent.CodingKeys.descriptionContents)) ?? []
            consequenceContents = (try? container.decode([OJPv2.ConsequenceContent].self, forKey: CodingKeys.consequenceContents)) ?? []
            recommendationContents = (try? container.decode([OJPv2.RecommendationContent].self, forKey: CodingKeys.recommendationContents)) ?? []
            durationContent = try container.decodeIfPresent(OJPv2.DurationContent.self, forKey: CodingKeys.durationContent)
            remarkContents = (try? container.decodeIfPresent([OJPv2.RemarkContent].self, forKey: CodingKeys.remarkContents)) ?? []
            infoLinks = (try? container.decodeIfPresent([OJPv2.InfoLink].self, forKey: CodingKeys.infoLinks)) ?? []
        }
    }

    struct PassengerInformationAction: Codable, Sendable {
        public let textualContents: [TextualContent]

        public enum CodingKeys: String, CodingKey {
            case textualContents = "siri:TextualContent"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__PublishingActionStructure
    struct PublishingAction: Codable, Sendable {
        /// mandatory in schema, but currently optional here for backwards compatibilty. Will change in the future.
        public let publishAtScope: PublishAtScope?
        public let passengerInformationActions: [PassengerInformationAction]

        public enum CodingKeys: String, CodingKey {
            case publishAtScope = "siri:PublishAtScope"
            case passengerInformationActions = "siri:PassengerInformationAction"
        }
    }

    struct PublishAtScope: Codable, Sendable {
        public let scopeType: ScopeType
        public let affects: Affects

        public enum CodingKeys: String, CodingKey {
            case scopeType = "siri:ScopeType"
            case affects = "siri:Affects"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#local_type_typedef_16_4
    enum ScopeType: String, Codable, Sendable, Equatable {
        case unknown
        case stopPlace
        case line
        case route
        case publicTransportService
        case `operator`
        case city
        case area
        case stopPoint
        case stopPlaceComponent
        case place
        case network
        case vehicleJourney
        case datedVehicleJourney
        case connectionLink
        case interchange
        case allPT
        case general
        case road
        case undefined

        public init(from decoder: any Decoder) throws {
            let svc = try decoder.singleValueContainer()
            self = try .init(rawValue: svc.decode(String.self)) ?? .unknown
        }
    }

    struct PublishingActions: Codable, Sendable {
        public let publishingActions: [PublishingAction]

        public enum CodingKeys: String, CodingKey {
            case publishingActions = "siri:PublishingAction"
        }
    }

    struct PTSituation: Codable, Sendable {
        public let creationTime: Date
        public let version: Int
        public let alertCause: AlertCause
        public let participantRef: String
        public let situationNumber: String
        public let validityPeriod: [ValidityPeriod]

        /// Profil CH
        /// - 1 = Notfall
        /// - 2 = Nicht verwendet
        /// - 3 = Un-/Planmäßige Situation
        /// - 4 = allgemeine Information
        /// Optional according to siri-sx, but mandatory according to [Realisierungsvorgabe Profil CH SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten)
        public let priority: Int

        /// Optional according to siri-sx, but mandatory according to [Realisierungsvorgabe Profil CH SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten)
        public let publishingActions: PublishingActions?
        public private(set) var planned: Bool? = false

        public enum CodingKeys: String, CodingKey {
            case situationNumber = "siri:SituationNumber"
            case creationTime = "siri:CreationTime"
            case participantRef = "siri:ParticipantRef"
            case validityPeriod = "siri:ValidityPeriod"
            case publishingActions = "siri:PublishingActions"
            case alertCause = "siri:AlertCause"
            case version = "siri:Version"
            case priority = "siri:Priority"
            case planned = "siri:Planned"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__AffectsScopeStructure
    struct Affects: Codable, Sendable {
        let stopPoints: [AffectedStopPoint]

        public enum CodingKeys: String, CodingKey {
            case stopPoints = "siri:AffectedStopPoint"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/siri.html#type_siri__AffectedStopPointStructure
    struct AffectedStopPoint: Codable, Sendable {
        let stopPointRef: String

        public enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
        }
    }

    enum AlertCause: String, Codable, Sendable {
        case undefinedAlertCause
        case constructionWork
        case serviceDisruption
        case emergencyServicesCall
        case vehicleFailure
        case poorWeather
        case routeBlockage
        case technicalProblem
        case unknown
        case accident
        case specialEvent
        case congestion
        case maintenanceWork
    }

    struct ValidityPeriod: Codable, Sendable {
        public let startTime: Date
        /// Optional according to siri-sx, but mandatory according to [Realisierungsvorgabe Profil CH SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten)
        public let endTime: Date

        public enum CodingKeys: String, CodingKey {
            case startTime = "siri:StartTime"
            case endTime = "siri:EndTime"
        }
    }

    struct RoadSituation: Codable, Sendable {}

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripResultStructure)
    struct TripResult: Codable, Identifiable, Sendable {
        public let id: String
        public let tripType: TripTypeChoice
        public let tripFares: [TripFare]
        public private(set) var isAlternativeOption: Bool?

        public enum CodingKeys: String, CodingKey {
            case _0 = ""
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

        public init(trip: OJPv2.Trip) {
            tripType = .trip(trip)
            id = trip.id
            tripFares = []
            isAlternativeOption = nil
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(tripType, forKey: ._0)
            if let isAlternativeOption {
                try container.encode(isAlternativeOption, forKey: .isAlternativeOption)
            }
            if !tripFares.isEmpty {
                try container.encode(tripFares, forKey: .tripFares)
            }
        }

        public enum TripTypeChoice: Codable, Sendable {
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

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .trip(trip):
                    try container.encode(trip, forKey: .trip)
                case let .tripSummary(tripSummary):
                    try container.encode(tripSummary, forKey: .tripSummary)
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

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__TripStatusGroup
    /// - Note: OJP currently doesn't return `unplanned` or `delayed`
    struct TripStatus: Codable, Sendable {
//        public var unplanned: Bool
        public var cancelled: Bool
        public var deviation: Bool
//        public var delayed: Bool
        public var infeasible: Bool

        enum CodingKeys: String, CodingKey {
//            case unplanned = "Unplanned"
            case cancelled = "Cancelled"
            case deviation = "Deviation"
//            case delayed = "Delayed"
            case infeasible = "Infeasible"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.unplanned = try container.decode(Bool?.self, forKey: .unplanned) ?? false
            cancelled = try container.decode(Bool?.self, forKey: .cancelled) ?? false
            deviation = try container.decode(Bool?.self, forKey: .deviation) ?? false
//            self.delayed = try container.decode(Bool?.self, forKey: .delayed) ?? false
            infeasible = try container.decode(Bool?.self, forKey: .infeasible) ?? false
        }

        public init(cancelled: Bool, deviation: Bool, infeasible: Bool) {
            self.cancelled = cancelled
            self.deviation = deviation
            self.infeasible = infeasible
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripStructure
    struct Trip: Codable, Identifiable, Sendable {
        /// Unique within trip response. This ID must not be used over mutliple ``OJPv2/TripRequest``
        /// - Warning: This ID must not be used over mutliple ``OJPv2/TripRequest``. Use ``tripHash`` instead.
        public let id: String
        public let duration: Duration
        /// startTime respects  the time of a potential first `walk` leg and the ``OJPv2/ServiceDeparture/estimatedTime`` of the **first** ``OJPv2/TimedLeg``. Use this value with caution!
        public let startTime: Date
        /// endTime respects the time of a potential last `walk` leg and the ``OJPv2/ServiceArrival/estimatedTime`` of the **last** ``OJPv2/TimedLeg``. Use this value with caution!
        public let endTime: Date
        public let transfers: Int
        public let distance: Double?
        public let legs: [Leg]
        public let tripStatus: TripStatus?

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
            case startTime = "StartTime"
            case endTime = "EndTime"
            case transfers = "Transfers"
            case distance = "Distance"
            case legs = "Leg"
            case tripStatus = "TripStatus"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: OJPv2.Trip.CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            duration = try container.decode(Duration.self, forKey: .duration)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decode(Date.self, forKey: .endTime)
            transfers = try container.decode(Int.self, forKey: .transfers)
            distance = try container.decodeIfPresent(Double.self, forKey: .distance)
            legs = try container.decode([OJPv2.Leg].self, forKey: .legs)
            tripStatus = try TripStatus(from: decoder)
        }

        public init(
            id: String,
            duration: Duration,
            startTime: Date,
            endTime: Date,
            transfers: Int,
            distance: Double? = nil,
            legs: [Leg],
            tripStatus: TripStatus? = nil
        ) {
            self.id = id
            self.duration = duration
            self.startTime = startTime
            self.endTime = endTime
            self.transfers = transfers
            self.distance = distance
            self.legs = legs
            self.tripStatus = tripStatus
        }

        /// Trip hash similar to the implementation in the JS SDK.
        /// Can be used to de-duplicate trips in ``OJPv2/TripResult``
        public var tripHash: Int {
            var h = Hasher()

            for leg in legs {
                switch leg.legType {
                case let .continous(continuousLeg):
                    switch continuousLeg.service.type {
                    case let .personalService(personalService):
                        h.combine(personalService.personalMode)
                    case let .datedJourney(datedJourney):
                        h.combine(datedJourney.journeyRef)
                    }
                    h.combine(continuousLeg.legStart)
                    h.combine(continuousLeg.legEnd)
                case let .timed(timedLeg):
                    h.combine(timedLeg.service.publishedServiceName.text)
                    h.combine(timedLeg.service.destinationText?.text)
                    h.combine(timedLeg.legBoard.stopPointName.text)
                    h.combine(timedLeg.legBoard.serviceDeparture.timetabledTime)
                    h.combine(timedLeg.legAlight.serviceArrival.timetabledTime)
                    h.combine(timedLeg.legAlight.stopPointName.text)
                    h.combine(timedLeg.service.trainNumber)
                case let .transfer(transferLeg):
                    h.combine(transferLeg.transferTypes.hashValue)
                    h.combine(transferLeg.duration)
                }
            }
            return h.finalize()
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegStructure
    struct Leg: Codable, Identifiable, Sendable {
        public let id: Int
        public let duration: Duration?
        public let legType: LegTypeChoice

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
            case _0 = ""
        }

        public init(from decoder: any Decoder) throws {
            legType = try LegTypeChoice(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            duration = try container.decodeIfPresent(Duration.self, forKey: .duration)
        }

        public init(id: Int, duration: Duration? = nil, legType: LegTypeChoice) {
            self.id = id
            self.duration = duration
            self.legType = legType
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(duration, forKey: .duration)
            try container.encode(legType, forKey: ._0)
        }

        public enum LegTypeChoice: Codable, Sendable {
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

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .continous(continuousLeg):
                    try container.encode(continuousLeg, forKey: CodingKeys.continous)
                case let .timed(timedLeg):
                    try container.encode(timedLeg, forKey: CodingKeys.timed)
                case let .transfer(transferLeg):
                    try container.encode(transferLeg, forKey: CodingKeys.transfer)
                }
            }
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TransferTypeEnumeration
    enum TransferType: String, Codable, Sendable {
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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TransferLegStructure)
    struct TransferLeg: Codable, Sendable {
        public let transferTypes: [TransferType]
        public let legStart: PlaceRefChoice
        public let legEnd: PlaceRefChoice
        public let duration: Duration
        /// Distance (metres) as defined by http://www.ordnancesurvey.co.uk/xml/resource/units.xml#metres. Alternative units may be specifed by context.
        public let length: Int?
        public let pathGuidance: PathGuidance?

        enum CodingKeys: String, CodingKey {
            case transferTypes = "TransferType"
            case duration = "Duration"
            case legStart = "LegStart"
            case legEnd = "LegEnd"
            case length = "Length"
            case pathGuidance = "PathGuidance"
        }

        public init(transferTypes: [TransferType], legStart: PlaceRefChoice, legEnd: PlaceRefChoice, duration: Duration, length: Int? = nil, pathGuidance: PathGuidance? = nil) {
            self.transferTypes = transferTypes
            self.legStart = legStart
            self.legEnd = legEnd
            self.duration = duration
            self.length = length
            self.pathGuidance = pathGuidance
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TimedLegStructure
    struct TimedLeg: Codable, Sendable {
        public let legBoard: LegBoard
        public let legsIntermediate: [LegIntermediate]
        public let legAlight: LegAlight
        public let service: DatedJourney
        public let legTrack: LegTrack?

        enum CodingKeys: String, CodingKey {
            case legBoard = "LegBoard"
            case legsIntermediate = "LegIntermediate"
            case legAlight = "LegAlight"
            case service = "Service"
            case legTrack = "LegTrack"
        }

        public init(legBoard: LegBoard, legsIntermediate: [LegIntermediate] = [], legAlight: LegAlight, service: DatedJourney, legTrack: LegTrack? = nil) {
            self.legBoard = legBoard
            self.legsIntermediate = legsIntermediate
            self.legAlight = legAlight
            self.service = service
            self.legTrack = legTrack
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ServiceArrivalStructure
    struct ServiceArrival: Codable, Sendable, Hashable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }

        init(timetabledTime: Date, estimatedTime: Date? = nil) {
            self.timetabledTime = timetabledTime
            self.estimatedTime = estimatedTime
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ServiceDepartureStructure
    struct ServiceDeparture: Codable, Sendable, Hashable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }

        init(timetabledTime: Date, estimatedTime: Date? = nil) {
            self.timetabledTime = timetabledTime
            self.estimatedTime = estimatedTime
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegBoardStructure
    struct LegBoard: Codable, Sendable {
        /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival?
        public let serviceDeparture: ServiceDeparture

        public let stopCallStatus: StopCallStatus?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus = "StopCallStatus"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopPointRef = try container.decode(String.self, forKey: .stopPointRef)
            stopPointName = try container.decode(InternationalText.self, forKey: .stopPointName)
            nameSuffix = try container.decode(InternationalText?.self, forKey: .nameSuffix)
            plannedQuay = try container.decode(InternationalText?.self, forKey: .plannedQuay)
            estimatedQuay = try container.decode(InternationalText?.self, forKey: .estimatedQuay)
            serviceArrival = try container.decode(ServiceArrival?.self, forKey: .serviceArrival)
            serviceDeparture = try container.decode(ServiceDeparture.self, forKey: .serviceDeparture)
            stopCallStatus = try StopCallStatus(from: decoder)
        }

        public init(
            stopPointRef: String,
            stopPointName: InternationalText,
            nameSuffix: InternationalText? = nil,
            plannedQuay: InternationalText? = nil,
            estimatedQuay: InternationalText? = nil,
            serviceArrival: ServiceArrival? = nil,
            serviceDeparture: ServiceDeparture,
            stopCallStatus: StopCallStatus? = nil
        ) {
            self.stopPointRef = stopPointRef
            self.stopPointName = stopPointName
            self.nameSuffix = nameSuffix
            self.plannedQuay = plannedQuay
            self.estimatedQuay = estimatedQuay
            self.serviceArrival = serviceArrival
            self.serviceDeparture = serviceDeparture
            self.stopCallStatus = stopCallStatus
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegIntermediateStructure
    struct LegIntermediate: Codable, Sendable {
        /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed
        public let serviceDeparture: ServiceDeparture? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed

        public let stopCallStatus: StopCallStatus?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus = "StopCallStatus"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopPointRef = try container.decode(String.self, forKey: .stopPointRef)
            stopPointName = try container.decode(InternationalText.self, forKey: .stopPointName)
            nameSuffix = try container.decode(InternationalText?.self, forKey: .nameSuffix)
            plannedQuay = try container.decode(InternationalText?.self, forKey: .plannedQuay)
            estimatedQuay = try container.decode(InternationalText?.self, forKey: .estimatedQuay)
            serviceArrival = try container.decode(ServiceArrival?.self, forKey: .serviceArrival)
            serviceDeparture = try container.decode(ServiceDeparture?.self, forKey: .serviceDeparture)
            stopCallStatus = try StopCallStatus(from: decoder)
        }

        public init(stopPointRef: String, stopPointName: OJPv2.InternationalText, nameSuffix: OJPv2.InternationalText? = nil, plannedQuay: OJPv2.InternationalText? = nil, estimatedQuay: OJPv2.InternationalText? = nil, serviceArrival: OJPv2.ServiceArrival? = nil, serviceDeparture: OJPv2.ServiceDeparture? = nil, stopCallStatus: OJPv2.StopCallStatus? = nil) {
            self.stopPointRef = stopPointRef
            self.stopPointName = stopPointName
            self.nameSuffix = nameSuffix
            self.plannedQuay = plannedQuay
            self.estimatedQuay = estimatedQuay
            self.serviceArrival = serviceArrival
            self.serviceDeparture = serviceDeparture
            self.stopCallStatus = stopCallStatus
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegAlightStructure
    struct LegAlight: Codable, Sendable {
        /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival
        public let serviceDeparture: ServiceDeparture?

        public let stopCallStatus: StopCallStatus?

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus = "StopCallStatus"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopPointRef = try container.decode(String.self, forKey: .stopPointRef)
            stopPointName = try container.decode(InternationalText.self, forKey: .stopPointName)
            nameSuffix = try container.decode(InternationalText?.self, forKey: .nameSuffix)
            plannedQuay = try container.decode(InternationalText?.self, forKey: .plannedQuay)
            estimatedQuay = try container.decode(InternationalText?.self, forKey: .estimatedQuay)
            serviceArrival = try container.decode(ServiceArrival.self, forKey: .serviceArrival)
            serviceDeparture = try container.decode(ServiceDeparture?.self, forKey: .serviceDeparture)
            stopCallStatus = try StopCallStatus(from: decoder)
        }

        public init(
            stopPointRef: String,
            stopPointName: InternationalText,
            nameSuffix: InternationalText? = nil,
            plannedQuay: InternationalText? = nil,
            estimatedQuay: InternationalText? = nil,
            serviceArrival: ServiceArrival,
            serviceDeparture: ServiceDeparture? = nil,
            stopCallStatus: StopCallStatus? = nil
        ) {
            self.stopPointRef = stopPointRef
            self.stopPointName = stopPointName
            self.nameSuffix = nameSuffix
            self.plannedQuay = plannedQuay
            self.estimatedQuay = estimatedQuay
            self.serviceArrival = serviceArrival
            self.serviceDeparture = serviceDeparture
            self.stopCallStatus = stopCallStatus
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__StopCallStatusGroup
    struct StopCallStatus: Codable, Sendable, Hashable {
        public let order: Int?
        public let requestStop: Bool
        public let unplannedStop: Bool
        public let notServicedStop: Bool
        public let noBoardingAtStop: Bool
        public let noAlightingAtStop: Bool

        enum CodingKeys: String, CodingKey {
            case order = "Order"
            case requestStop = "RequestStop"
            case unplannedStop = "UnplannedStop"
            case notServicedStop = "NotServicedStop"
            case noBoardingAtStop = "NoBoardingAtStop"
            case noAlightingAtStop = "NoAlightingAtStop"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            order = try container.decodeIfPresent(Int.self, forKey: .order)
            requestStop = try container.decodeIfPresent(Bool.self, forKey: .requestStop) ?? false
            unplannedStop = try container.decodeIfPresent(Bool.self, forKey: .unplannedStop) ?? false
            notServicedStop = try container.decodeIfPresent(Bool.self, forKey: .notServicedStop) ?? false
            noBoardingAtStop = try container.decodeIfPresent(Bool.self, forKey: .noBoardingAtStop) ?? false
            noAlightingAtStop = try container.decodeIfPresent(Bool.self, forKey: .noAlightingAtStop) ?? false
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ProductCategoryStructure
    struct ProductCategory: Codable, Sendable {
        public let name: InternationalText?
        public let shortName: InternationalText?
        public let productCategoryRef: String?

        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case shortName = "ShortName"
            case productCategoryRef = "ProductCategoryRef"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__GeneralAttributeStructure
    struct Attribute: Codable, Sendable {
        public let userText: InternationalText
        public let code: String

        public enum CodingKeys: String, CodingKey {
            case userText = "UserText"
            case code = "Code"
        }
    }

    struct SituationFullRef: Codable, Sendable {
        public let participantRef: String
        public let situationNumber: String

        enum CodingKeys: String, CodingKey {
            case participantRef = "siri:ParticipantRef"
            case situationNumber = "siri:SituationNumber"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__SituationRefList
    struct SituationFullRefs: Codable, Sendable {
        public let situationFullRefs: [SituationFullRef]

        enum CodingKeys: String, CodingKey {
            case situationFullRefs = "SituationFullRef"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__ServiceStatusGroup
    /// - WARNING: This is information currently not provided by OJP in Switzerland. See comment on [GitHub](https://github.com/openTdataCH/ojp-sdk/issues/41#issuecomment-2304431303)
    struct ServiceStatusGroup: Codable, Sendable {
        public let unplanned: Bool
        public let cancelled: Bool
        public let deviation: Bool
        public let undefinedDelay: Bool

        public enum CodingKeys: String, CodingKey {
            case unplanned = "Unplanned"
            case cancelled = "Cancelled"
            case deviation = "Deviation"
            case undefinedDelay = "UndefinedDelay"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            unplanned = try container.decode(Bool?.self, forKey: .unplanned) ?? false
            cancelled = try container.decode(Bool?.self, forKey: .cancelled) ?? false
            deviation = try container.decode(Bool?.self, forKey: .deviation) ?? false
            undefinedDelay = try container.decode(Bool?.self, forKey: .undefinedDelay) ?? false
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__DatedJourneyStructure
    struct DatedJourney: Codable, Sendable {
        /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ConventionalModesOfOperationEnumeration
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
        public let situationFullRefs: SituationFullRefs?
        public let serviceStatus: ServiceStatusGroup?

        public enum CodingKeys: String, CodingKey {
            case conventionalModeOfOperation = "ConventionalModeOfOperation"
            case operatingDayRef = "OperatingDayRef"
            case journeyRef = "JourneyRef"
            case publicCode = "PublicCode"
            case lineRef = "siri:LineRef"
            case directionRef = "siri:DirectionRef"
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
            case situationFullRefs = "SituationFullRefs"
            case serviceStatus = "ServiceStatus"
        }

        public enum ConventionalModesOfOperation: String, Codable, Sendable {
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

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            conventionalModeOfOperation = try container.decodeIfPresent(OJPv2.DatedJourney.ConventionalModesOfOperation.self, forKey: .conventionalModeOfOperation)
            operatingDayRef = try container.decode(String.self, forKey: .operatingDayRef)
            journeyRef = try container.decode(String.self, forKey: .journeyRef)
            publicCode = try container.decodeIfPresent(String.self, forKey: .publicCode)
            lineRef = try container.decode(String.self, forKey: .lineRef)
            directionRef = try container.decodeIfPresent(String.self, forKey: .directionRef)
            mode = try container.decode(OJPv2.Mode.self, forKey: .mode)
            productCategory = try container.decodeIfPresent(OJPv2.ProductCategory.self, forKey: .productCategory)
            publishedServiceName = try container.decode(OJPv2.InternationalText.self, forKey: .publishedServiceName)
            trainNumber = try container.decodeIfPresent(String.self, forKey: .trainNumber)
            vehicleRef = try container.decodeIfPresent(String.self, forKey: .vehicleRef)
            attributes = try container.decode([OJPv2.Attribute].self, forKey: .attributes)
            operatorRef = try container.decodeIfPresent(String.self, forKey: .operatorRef)
            originText = try container.decode(OJPv2.InternationalText.self, forKey: .originText)
            originStopPointRef = try container.decodeIfPresent(String.self, forKey: .originStopPointRef)
            destinationText = try container.decodeIfPresent(OJPv2.InternationalText.self, forKey: .destinationText)
            destinationStopPointRef = try container.decodeIfPresent(String.self, forKey: .destinationStopPointRef)
            situationFullRefs = try container.decodeIfPresent(OJPv2.SituationFullRefs.self, forKey: .situationFullRefs)
            serviceStatus = try ServiceStatusGroup(from: decoder)
        }

        public init(
            conventionalModeOfOperation: ConventionalModesOfOperation? = nil,
            operatingDayRef: String,
            journeyRef: String,
            publicCode: String? = nil,
            lineRef: String,
            directionRef: String? = nil,
            mode: Mode,
            productCategory: ProductCategory? = nil,
            publishedServiceName: InternationalText,
            trainNumber: String? = nil,
            vehicleRef: String? = nil,
            attributes: [Attribute] = [],
            operatorRef: String? = nil,
            originText: InternationalText,
            originStopPointRef: String? = nil,
            destinationText: InternationalText? = nil,
            destinationStopPointRef: String? = nil,
            situationFullRefs: SituationFullRefs? = nil,
            serviceStatus: ServiceStatusGroup? = nil
        ) {
            self.conventionalModeOfOperation = conventionalModeOfOperation
            self.operatingDayRef = operatingDayRef
            self.journeyRef = journeyRef
            self.publicCode = publicCode
            self.lineRef = lineRef
            self.directionRef = directionRef
            self.mode = mode
            self.productCategory = productCategory
            self.publishedServiceName = publishedServiceName
            self.trainNumber = trainNumber
            self.vehicleRef = vehicleRef
            self.attributes = attributes
            self.operatorRef = operatorRef
            self.originText = originText
            self.originStopPointRef = originStopPointRef
            self.destinationText = destinationText
            self.destinationStopPointRef = destinationStopPointRef
            self.situationFullRefs = situationFullRefs
            self.serviceStatus = serviceStatus
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LinearShapeStructure
    struct LinearShape: Codable, Sendable {
        // in XSD min 2 <GeoPosition> elements are required
        public let positions: [GeoPosition]

        public enum CodingKeys: String, CodingKey {
            case positions = "Position"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__PathGuidanceSectionStructure)
    struct PathGuidanceSection: Codable, Sendable {
        public let trackSections: [TrackSection]

        public enum CodingKeys: String, CodingKey {
            case trackSections = "TrackSection"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__PathGuidanceStructure)
    struct PathGuidance: Codable, Sendable {
        public let pathGuidanceSection: [PathGuidanceSection]

        public enum CodingKeys: String, CodingKey {
            case pathGuidanceSection = "PathGuidanceSection"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TrackSectionStructure
    struct TrackSection: Codable, Sendable {
        public let trackSectionStart: PlaceRefChoice?
        public let trackSectionEnd: PlaceRefChoice?
        public let linkProjection: LinearShape?
        /// Duration the passenger needs to travel through this track section.
        public let duration: Duration?
        /// Distance (metres) as defined by http://www.ordnancesurvey.co.uk/xml/resource/units.xml#metres. Alternative units may be specifed by context.
        public let length: Int?

        public enum CodingKeys: String, CodingKey {
            case trackSectionStart = "TrackSectionStart"
            case trackSectionEnd = "TrackSectionEnd"
            case linkProjection = "LinkProjection"
            case duration = "Duration"
            case length = "Length"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__LegTrackStructure
    struct LegTrack: Codable, Sendable {
        public let trackSections: [TrackSection]

        public enum CodingKeys: String, CodingKey {
            case trackSections = "TrackSection"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ContinuousLegStructure
    struct ContinuousLeg: Codable, Sendable {
        public let legStart: PlaceRefChoice
        public let legEnd: PlaceRefChoice
        public let duration: Duration
        public let service: ContinuousService
        public let legTrack: LegTrack?

        enum CodingKeys: String, CodingKey {
            case legStart = "LegStart"
            case legEnd = "LegEnd"
            case duration = "Duration"
            case service = "Service"
            case legTrack = "LegTrack"
        }

        public init(legStart: PlaceRefChoice, legEnd: PlaceRefChoice, duration: Duration, service: ContinuousService, legTrack: LegTrack? = nil) {
            self.legStart = legStart
            self.legEnd = legEnd
            self.duration = duration
            self.service = service
            self.legTrack = legTrack
        }
    }

    struct PersonalService: Codable, Sendable {
        let personalMode: String

        enum CodingKeys: String, CodingKey {
            case personalMode = "PersonalMode"
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ContinuousServiceStructure
    enum ContinuousServiceTypeChoice: Codable, Sendable {
        case personalService(PersonalService)
        case datedJourney(DatedJourney)

        public init(from decoder: any Decoder) throws {
            do {
                self = try .personalService(PersonalService(from: decoder))
            } catch {
                self = try .datedJourney(DatedJourney(from: decoder))
            }
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ContinuousServiceStructure
    struct ContinuousService: Codable, Sendable {
        public let type: ContinuousServiceTypeChoice
        // TODO: add SituationFullRefs!

        public init(from decoder: any Decoder) throws {
            type = try ContinuousServiceTypeChoice(from: decoder)
        }

        public init(type: ContinuousServiceTypeChoice) {
            self.type = type
        }
    }

    struct TripSummary: Codable, Sendable {}

    struct TripFare: Codable, Sendable {}

    struct TripRequest: Codable, Sendable {
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

    struct PlaceContext: Codable, Sendable {
        public let placeRef: PlaceRefChoice
        public let depArrTime: Date?

        public init(placeRef: PlaceRefChoice, depArrTime: Date?) {
            self.placeRef = placeRef
            self.depArrTime = depArrTime
        }

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
            case depArrTime = "DepArrTime"
        }
    }

    struct TripVia: Codable, Sendable {
        public let viaPoint: PlaceRefChoice

        public enum CodingKeys: String, CodingKey {
            case viaPoint = "ViaPoint"
        }
    }

    struct StopPlaceRef: Codable, Sendable {
        public let stopPlaceRef: String
        public let name: InternationalText

        public init(stopPlaceRef: String, name: InternationalText) {
            self.stopPlaceRef = stopPlaceRef
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case name = "Name"
        }
    }

    struct StopPointRef: Codable, Sendable {
        public let stopPointRef: String
        public let name: InternationalText

        public init(stopPointRef: String, name: InternationalText) {
            self.stopPointRef = stopPointRef
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case name = "Name"
        }
    }

    struct GeoPositionRef: Codable, Sendable {
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

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__PlaceRefGroup
    enum PlaceRefChoice: Codable, Sendable {
        case stopPlaceRef(StopPlaceRef)
        case geoPosition(GeoPositionRef)
        case stopPointRef(StopPointRef)
        case topographicPlaceRef(String)

        enum CodingKeys: String, CodingKey {
//            case stopPlaceRef = "StopPlaceRef"
//            case stopPointRef = "siri:StopPointRef"
//            case name = "Name"
            case topographicPlaceRef = "TopographicPlaceRef"
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
            case let .topographicPlaceRef(topographicPlaceRef):
                try svc.encode(topographicPlaceRef)
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
            } else if try decoder.container(keyedBy: PlaceRefChoice.CodingKeys.self)
                .contains(.topographicPlaceRef)
            {
                self = try .topographicPlaceRef(
                    svc.decode(String.self)
                )

            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__ModeAndModeOfOperationFilterStructure
    struct ModeAndModeOfOperationFilter: Codable, Sendable {
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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__UseRealtimeDataEnumeration)
    enum UseRealtimeData: String, Sendable, Codable {
        case explanatory
        case full
        case none
    }

    /// https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TripParamStructure
    struct TripParams: Codable, Sendable {
        public init(
            numberOfResults: NumberOfResults = .standard(10),
            includeTrackSections: Bool? = nil,
            includeLegProjection: Bool? = nil,
            includeTurnDescription: Bool? = nil,
            includeIntermediateStops: Bool? = nil,
            includeAllRestrictedLines: Bool? = nil,
            useRealtimeData: UseRealtimeData? = nil,
            modeAndModeOfOperationFilter: ModeAndModeOfOperationFilter? = nil

        ) {
            switch numberOfResults {
            case let .numbers(before: before, after: after):
                numberOfResultsBefore = before > 0 ? before : nil
                numberOfResultsAfter = after > 0 ? after : nil
            case let .standard(count):
                _numberOfResults = count
            }

            self.includeTrackSections = includeTrackSections
            self.includeLegProjection = includeLegProjection
            self.includeTurnDescription = includeTurnDescription
            self.includeIntermediateStops = includeIntermediateStops
            self.includeAllRestrictedLines = includeAllRestrictedLines
            self.useRealtimeData = useRealtimeData
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
        let useRealtimeData: UseRealtimeData?
        let modeAndModeOfOperationFilter: ModeAndModeOfOperationFilter?

        var numberOfResults: NumberOfResults {
            if numberOfResultsAfter != nil || numberOfResultsBefore != nil {
                return .numbers(
                    before: numberOfResultsBefore ?? 0,
                    after: numberOfResultsAfter ?? 0
                )
            }
            return .standard(_numberOfResults ?? 10)
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
            case useRealtimeData = "UseRealtimeData"
            case modeAndModeOfOperationFilter = "ModeAndModeOfOperationFilter"
        }
    }

    /// Convenience enum to define [NumberOfResults](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#group_ojp__NumberOfResultsGroup)
    enum NumberOfResults: Codable, Sendable {
        case numbers(before: Int, after: Int)
        case standard(Int)
    }
}

// MARK: - A bit more convenience for the Situations

extension OJPv2.PTSituation: Identifiable, Hashable {
    public static func == (lhs: OJPv2.PTSituation, rhs: OJPv2.PTSituation) -> Bool {
        lhs.id == rhs.id
    }

    public var id: String { situationNumber }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(situationNumber)
    }
}

extension OJPv2.PublishingActions: Hashable {
    public func hash(into hasher: inout Hasher) {
        for publishingAction in publishingActions {
            hasher.combine(publishingAction)
        }
    }
}

extension OJPv2.PublishAtScope: Hashable {}

extension OJPv2.Affects: Hashable {}

extension OJPv2.AffectedStopPoint: Hashable {}

extension OJPv2.PublishingAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        passengerInformationActions.forEach { hasher.combine($0) }
    }
}

extension OJPv2.PassengerInformationAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        for textualContent in textualContents {
            hasher.combine(textualContent)
        }
    }
}

extension OJPv2.TextualContent: Hashable {
    public static func == (lhs: OJPv2.TextualContent, rhs: OJPv2.TextualContent) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(summaryContent)
        hasher.combine(reasonContent)
        hasher.combine(descriptionContents)
        hasher.combine(consequenceContents)
        hasher.combine(recommendationContents)
        hasher.combine(durationContent)
        hasher.combine(remarkContents)
    }
}

extension OJPv2.SummaryContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(summaryText)
    }
}

extension OJPv2.ReasonContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(reasonText)
    }
}

extension OJPv2.DescriptionContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(descriptionText)
    }
}

extension OJPv2.ConsequenceContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(consequenceText)
    }
}

extension OJPv2.RecommendationContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(recommendationText)
    }
}

extension OJPv2.RemarkContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(remarkText)
    }
}

extension OJPv2.DurationContent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(durationText)
    }
}
