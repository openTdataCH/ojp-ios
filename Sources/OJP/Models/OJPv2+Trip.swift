//
//  OJPv2+Trip.swift
//
//
//  Created by Terence Alberti on 06.05.2024.
//

import Foundation

public extension OJPv2 {
    internal struct TripDelivery: Codable {
        public let calcTime: Int?
        public let tripResults: [TripResult]

        public enum CodingKeys: String, CodingKey {
            case calcTime = "CalcTime"
            case tripResults = "TripResult"
        }
    }

    struct TripResult: Codable {
        public let id: String
        public let tripType: TripType
        public let tripFares: [TripFare]
        public let isAlternativeOption: Bool?

        public enum CodingKeys: String, CodingKey {
            case id = "Id"
            case tripFares = "TripFare"
            case isAlternativeOption = "IsAlternativeOption"
        }

        public init(from decoder: any Decoder) throws {
            tripType = try TripType(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            id = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.id))
            tripFares = try container.decode([TripFare].self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.tripFares))
            isAlternativeOption = try? container.decode(Bool.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.isAlternativeOption))
        }

        public enum TripType: Codable {
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
        public let legs: [Leg]

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
            case startTime = "StartTime"
            case endTime = "EndTime"
            case transfers = "Transfers"
            case legs = "Leg"
        }
    }

    struct Leg: Codable {
        public let id: Int
        public let duration: String?
        public let legType: LegType

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case duration = "Duration"
        }

        public init(from decoder: any Decoder) throws {
            legType = try LegType(from: decoder)

            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            id = try container.decode(Int.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.id))
            duration = try? container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.duration))
        }

        public enum LegType: Codable {
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

    struct TransferLeg: Codable {}

    struct TimedLeg: Codable {
        public let legBoard: LegBoard
        public let legAlight: LegAlight
        public let service: Service

        enum CodingKeys: String, CodingKey {
            case legBoard = "LegBoard"
            case legAlight = "LegAlight"
            case service = "Service"
        }
    }

    struct LegBoard: Codable {}

    struct LegAlight: Codable {}

    struct Service: Codable {}

    struct ContinuousLeg: Codable {}

    struct TripSummary: Codable {}

    struct TripFare: Codable {}

    internal struct TripRequest: Codable {
        public let requestTimestamp: String
        public let requestorRef: String
            
        public let origin: Origin
        public let destination: Destination
        public let via: [TripVia]?
        public let params: Params?

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case origin = "Origin"
            case destination = "Destination"
            case via = "Via"
            case params = "Params"
        }
    }

    internal struct Origin: Codable {
        public let placeRef: PlaceRef
        public let depArrTime: String

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
            case depArrTime = "DepArrTime"
        }
    }

    internal struct Destination: Codable {
        public let placeRef: PlaceRef

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
        }
    }

    internal struct TripVia: Codable {
        public let viaPoint: PlaceRef

        public enum CodingKeys: String, CodingKey {
            case viaPoint = "ViaPoint"
        }
    }

    internal struct PlaceRef: Codable {
        public let stopPlaceRef: String

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
        }
    }

    internal struct Params: Codable {
        public let numberOfResultsBefore: Int
        public let numberOfResultsAfter: Int
        public let includeTrackSections: Bool
        public let includeLegProjection: Bool
        public let includeTurnDescription: Bool
        public let includeIntermediateStops: Bool

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
