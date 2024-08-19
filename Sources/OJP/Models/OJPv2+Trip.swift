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
extension Duration: @unchecked Sendable {}

// TODO: can be removed as soon as XMLCoder conforms to Sendable
extension XMLEncoder.OutputFormatting: @unchecked Sendable {}

public extension OJPv2 {
    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/index.html#OJPTripDeliveryStructure)
    struct TripDelivery: Codable, Sendable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let calcTime: Int?
        public let tripResponseContext: TripResponseContext?
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
            tripResponseContext = try container.decodeIfPresent(OJPv2.TripResponseContext.self, forKey: .tripResponseContext)
            tripResults = (try? container.decode([OJPv2.TripResult].self, forKey: .tripResults)) ?? [] // tripResults could be optional
        }
    }

    struct TripResponseContext: Codable, Sendable {
        public let situations: Situation

        public enum CodingKeys: String, CodingKey {
            case situations = "Situations"
        }
    }

    /// https://vdvde.github.io/OJP/develop/index.html#SituationsStructure
    struct Situation: Codable, Sendable {
        let ptSituations: [PTSituation]?
        let roadSituations: [RoadSituation]?

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
            case remarkText = "siri:RemarkText"
        }
    }

    struct DurationContent: Codable, Sendable {
        public let durationText: String

        public enum CodingKeys: String, CodingKey {
            case durationText = "siri:DurationText"
        }
    }

    struct TextualContent: Codable, Sendable {
        public let summaryContent: SummaryContent
        public let reasonContent: ReasonContent?
        public let descriptionContents: [DescriptionContent]
        public let consequenceContents: [ConsequenceContent]
        public let recommendationContents: [RecommendationContent]
        public let durationContent: DurationContent?
        public let remarkContents: [RemarkContent]

        public enum CodingKeys: String, CodingKey {
            case summaryContent = "siri:SummaryContent"
            case reasonContent = "siri:ReasonContent"
            case descriptionContents = "siri:DescriptionContent"
            case consequenceContents = "siri:ConsequenceContent"
            case recommendationContents = "siri:RecommendationContent"
            case durationContent = "siri:DurationContent"
            case remarkContents = "siri:RemarkContent"
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
        }
    }

    struct PassengerInformationAction: Codable, Sendable {
        public let textualContents: [TextualContent]

        public enum CodingKeys: String, CodingKey {
            case textualContents = "siri:TextualContent"
        }
    }

    struct PublishingAction: Codable, Sendable {
        public let passengerInformationActions: [PassengerInformationAction]

        public enum CodingKeys: String, CodingKey {
            case passengerInformationActions = "siri:PassengerInformationAction"
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
        public let affects: Affects?

        /// Profil CH
        /// - 1 = Notfall
        /// - 2 = Nicht verwendet
        /// - 3 = Un-/Planmäßige Situation
        /// - 4 = allgemeine Information
        /// Optional according to siri-sx, but mandatory according to [Realisierungsvorgabe Profil CH SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten)
        public let priority: Int

        /// Optional according to siri-sx, but mandatory according to [Realisierungsvorgabe Profil CH SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten)
        public let publishingActions: PublishingActions
        public private(set) var planned: Bool? = false

        public enum CodingKeys: String, CodingKey {
            case situationNumber = "siri:SituationNumber"
            case creationTime = "siri:CreationTime"
            case participantRef = "siri:ParticipantRef"
            case validityPeriod = "siri:ValidityPeriod"
            case affects = "siri:Affects"
            case publishingActions = "siri:PublishingActions"
            case alertCause = "siri:AlertCause"
            case version = "siri:Version"
            case priority = "siri:Priority"
            case planned = "siri:Planned"
        }
    }

    struct Affects: Codable, Sendable {
        let stopPoints: [AffectedStopPoint]

        public enum CodingKeys: String, CodingKey {
            case stopPoints = "siri:AffectedStopPoint"
        }
    }

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

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/index.html#TripResultStructure)
    struct TripResult: Codable, Identifiable, Sendable {
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
        }

        /// convenience property to access the underlying trip (as TripSummary is currently not supported)
        public var trip: Trip? {
            if case let .trip(trip) = tripType {
                return trip
            }
            return nil
        }
    }

    /// https://vdvde.github.io/OJP/develop/index.html#TripStatusGroup
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
    }

    /// https://vdvde.github.io/OJP/develop/index.html#TripStructure
    struct Trip: Codable, Identifiable, Sendable {
        /// Unique within trip response. This ID must not be used over mutliple ``OJPv2/TripRequest``
        /// - Warning: This ID must not be used over mutliple ``OJPv2/TripRequest``. Use ``tripHash`` instead.
        public let id: String
        public let duration: Duration
        public let startTime: Date
        public let endTime: Date
        public let transfers: Int
        public let distance: Double?
        public let legs: [Leg]
        public let tripStatus: TripStatus

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
            case startTime = "StartTime"
            case endTime = "EndTime"
            case transfers = "Transfers"
            case distance = "Distance"
            case legs = "Leg"
            case tripStatus
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
    struct Leg: Codable, Identifiable, Sendable {
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
            duration = try container.decodeIfPresent(Duration.self, forKey: .duration)
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
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TransferTypeEnumeration
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

    // https://vdvde.github.io/OJP/develop/index.html#TransferLegStructure
    struct TransferLeg: Codable, Sendable {
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
    }

    // https://vdvde.github.io/OJP/develop/index.html#ServiceArrivalStructure
    struct ServiceArrival: Codable, Sendable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ServiceDepartureStructure
    struct ServiceDeparture: Codable, Sendable {
        public let timetabledTime: Date
        public let estimatedTime: Date?

        enum CodingKeys: String, CodingKey {
            case timetabledTime = "TimetabledTime"
            case estimatedTime = "EstimatedTime"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegBoardStructure
    struct LegBoard: Codable, Sendable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival?
        public let serviceDeparture: ServiceDeparture

        public let stopCallStatus: StopCallStatus

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus
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
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegIntermediateStructure
    struct LegIntermediate: Codable, Sendable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed
        public let serviceDeparture: ServiceDeparture? // Set as optional until https://github.com/openTdataCH/ojp-sdk/issues/42 is fixed

        public let stopCallStatus: StopCallStatus

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus
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
    }

    // https://vdvde.github.io/OJP/develop/index.html#LegAlightStructure
    struct LegAlight: Codable, Sendable {
        // https://vdvde.github.io/OJP/develop/index.html#StopPointGroup
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let nameSuffix: InternationalText?
        public let plannedQuay: InternationalText?
        public let estimatedQuay: InternationalText?

        public let serviceArrival: ServiceArrival
        public let serviceDeparture: ServiceDeparture?

        public let stopCallStatus: StopCallStatus

        enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case nameSuffix = "NameSuffix"
            case plannedQuay = "PlannedQuay"
            case estimatedQuay = "EstimatedQuay"
            case serviceArrival = "ServiceArrival"
            case serviceDeparture = "ServiceDeparture"
            case stopCallStatus
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
    }

    // https://vdvde.github.io/OJP/develop/index.html#StopCallStatusGroup
    struct StopCallStatus: Codable, Sendable {
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

    // https://vdvde.github.io/OJP/develop/index.html#ProductCategoryStructure
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

    // https://vdvde.github.io/OJP/develop/index.html#GeneralAttributeStructure
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

    // https://vdvde.github.io/OJP/develop/index.html#SituationRefList
    struct SituationFullRefs: Codable, Sendable {
        public let situationFullRefs: [SituationFullRef]

        enum CodingKeys: String, CodingKey {
            case situationFullRefs = "SituationFullRef"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#DatedJourneyStructure
    struct DatedJourney: Codable, Sendable {
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
        public let situationFullRefs: SituationFullRefs?

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
            case situationFullRefs = "SituationFullRefs"
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
    }

    // https://vdvde.github.io/OJP/develop/index.html#LinearShapeStructure
    struct LinearShape: Codable, Sendable {
        // in XSD min 2 <GeoPosition> elements are required
        public let positions: [GeoPosition]

        public enum CodingKeys: String, CodingKey {
            case positions = "Position"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#TrackSectionStructure
    struct TrackSection: Codable, Sendable {
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
    struct LegTrack: Codable, Sendable {
        public let trackSections: [TrackSection]

        public enum CodingKeys: String, CodingKey {
            case trackSections = "TrackSection"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ContinuousLegStructure
    struct ContinuousLeg: Codable, Sendable {
        public let legStart: PlaceRefChoice
        public let legEnd: PlaceRefChoice
        public let duration: Duration
        public let service: ContinuousService

        enum CodingKeys: String, CodingKey {
            case legStart = "LegStart"
            case legEnd = "LegEnd"
            case duration = "Duration"
            case service = "Service"
        }
    }

    struct PersonalService: Codable, Sendable {
        let personalMode: String

        enum CodingKeys: String, CodingKey {
            case personalMode = "PersonalMode"
        }
    }

    // https://vdvde.github.io/OJP/develop/index.html#ContinuousServiceStructure
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

    // https://vdvde.github.io/OJP/develop/index.html#ContinuousServiceStructure
    struct ContinuousService: Codable, Sendable {
        public let type: ContinuousServiceTypeChoice
        // TODO: add SituationFullRefs!

        public init(from decoder: any Decoder) throws {
            type = try ContinuousServiceTypeChoice(from: decoder)
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

    struct StopPointRef: Codable, Sendable {
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

    // https://vdvde.github.io/OJP/develop/index.html#PlaceRefGroup
    enum PlaceRefChoice: Codable, Sendable {
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

    // https://vdvde.github.io/OJP/develop/index.html#TripParamStructure
    struct TripParams: Codable, Sendable {
        public enum RealtimeData: String, Sendable, Codable {
            case explanatory
            case full
            case none
        }

        public init(
            numberOfResults: NumberOfResults = .minimum(10),
            includeTrackSections: Bool? = nil,
            includeLegProjection: Bool? = nil,
            includeTurnDescription: Bool? = nil,
            includeIntermediateStops: Bool? = nil,
            includeAllRestrictedLines: Bool? = nil,
            useRealtimeData: RealtimeData? = nil,
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
        let useRealtimeData: RealtimeData?
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
            case useRealtimeData = "UseRealtimeData"
            case modeAndModeOfOperationFilter = "ModeAndModeOfOperationFilter"
        }
    }

    /// Convenience enum to define [NumberOfResults](https://vdvde.github.io/OJP/develop/index.html#NumberOfResultsGroup)
    enum NumberOfResults: Codable, Sendable {
        case before(Int)
        case after(Int)
        case minimum(Int)
    }
}

// MARK: - A bit more convenience for the Situations

extension OJPv2.PTSituation: Identifiable {
    public var id: String { situationNumber }
}

extension OJPv2.PublishingActions: Hashable {
    public func hash(into hasher: inout Hasher) {
        for publishingAction in publishingActions {
            hasher.combine(publishingAction)
        }
    }
}

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
