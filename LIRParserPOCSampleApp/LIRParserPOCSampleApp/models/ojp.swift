//
//  ojp.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

struct OJP: Codable {
    let response: Response
    
    public enum CodingKeys: String, CodingKey {
        case response = "OJPResponse"
    }
    
    struct Response: Codable {
        let serviceDelivery: ServiceDelivery
        
        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "ServiceDelivery"
        }
    }
    
    struct ServiceDelivery: Codable {
        let responseTimestamp: String
        let producerRef: String
        let locationInformationDelivery: LocationInformationDelivery
        
        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "ResponseTimestamp"
            case producerRef = "ProducerRef"
            case locationInformationDelivery = "OJPLocationInformationDelivery"
        }
    }
    
    struct LocationInformationDelivery: Codable {
        let responseTimestamp: String
        let requestMessageRef: String
        let defaultLanguage: String
        let calcTime: String
        let placeResults: [PlaceResult]
        
        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "ResponseTimestamp"
            case requestMessageRef = "RequestMessageRef"
            case defaultLanguage = "DefaultLanguage"
            case calcTime = "CalcTime"
            case placeResults = "PlaceResult"
        }
    }
    
    struct PlaceResult: Codable {
        let place: Place
        let complete: Bool
        let probability: Float
        
        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }
    
    struct Place: Codable {
        let stopPlace: StopPlace
        let name: Name
        let geoPosition: GeoPosition
        
        public enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case name = "Name"
            case geoPosition = "GeoPosition"
        }
    }
    
    struct StopPlace: Codable {
        let stopPlaceRef: String
        let stopPlaceName: Name
        let privateCode: PrivateCode
        let topographicPlaceRef: String
        
        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCode = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }
    
    struct Name: Codable {
        let text: String
        
        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }
    
    struct PrivateCode: Codable {
        let system: String
        let value: String
        
        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }
    
    struct GeoPosition: Codable {
        let longitude: Double
        let latitude: Double
        
        public enum CodingKeys: String, CodingKey {
            case longitude = "Longitude"
            case latitude = "Latitude"
        }
    }
}
