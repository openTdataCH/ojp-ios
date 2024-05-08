//
//  File.swift
//  
//
//  Created by Terence Alberti on 06.05.2024.
//

import Foundation

extension OJPv2 {
    
    struct TripDelivery: Codable {
        public let calcTime: Int?
        public let tripResults: [TripResult]
        
        public enum CodingKeys: String, CodingKey {
            case calcTime = "CalcTime"
            case tripResults = "TripResult"
        }
    }
    
    public struct TripResult: Codable {
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
    
    public struct Trip: Codable {
        
    }
    
    public struct TripSummary: Codable {
        
    }
    
    public struct TripFare: Codable {
        
    }
    
    struct TripRequest: Codable {
        public let requestTimestamp: String
        public let origin: Origin
        public let destination: Destination
        public let via: [TripVia]?
        public let params: Params

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case origin = "Origin"
            case destination = "Destination"
            case via = "Via"
            case params = "Params"
        }
    }

    struct Origin: Codable {
        public let placeRef: PlaceRef
        public let depArrTime: String

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
            case depArrTime = "DepArrTime"
        }
    }

    struct Destination: Codable {
        public let placeRef: PlaceRef

        public enum CodingKeys: String, CodingKey {
            case placeRef = "PlaceRef"
        }
    }
    
    struct TripVia: Codable {
        public let viaPoint: PlaceRef

        public enum CodingKeys: String, CodingKey {
            case viaPoint = "ViaPoint"
        }
    }


    struct PlaceRef: Codable {
        public let stopPlaceRef: String

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
        }
    }

    struct Params: Codable {
        public let numberOfResults: Int
        public let transferLimit: Int
        public let optimisationMethod: String

        public enum CodingKeys: String, CodingKey {
            case numberOfResults = "NumberOfResults"
            case transferLimit = "TransferLimit"
            case optimisationMethod = "OptimisationMethod"
        }
    }
    
}





