//
//  OJPNamespaced.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

// Same as OJP but with namespaces
struct OJPNamespaced: Codable {
    let response: Response

    public enum CodingKeys: String, CodingKey {
        case response = "OJPResponse"
    }

    struct Response: Codable {
        let serviceDelivery: ServiceDelivery

        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "siri:ServiceDelivery"
        }
    }

    struct ServiceDelivery: Codable {
        let responseTimestamp: String
        let producerRef: String

        // for demo sake skip other members
        // let locationInformationDelivery: LocationInformationDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
        }
    }
}
