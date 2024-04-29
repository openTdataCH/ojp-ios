//
//  OJPDecoder.swift
//
//
//  Created by Lehnherr Reto on 18.03.2024.
//

import Foundation
import XMLCoder

enum OJPDecoder {
    static func parseXML<T: Decodable>(_: T.Type, _ xmlData: Data) throws -> T {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.dateDecodingStrategy = .iso8601
        // strips out namespaces from the response XML nodes
        decoder.shouldProcessNamespaces = true
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(T.self, from: xmlData)
    }

    static func parseXML(_ xmlData: Data) throws -> OJPv2 {
        try parseXML(OJPv2.self, xmlData)
    }

    static func response(_ xmlData: Data) throws -> OJPv2.Response {
        let xml = try parseXML(xmlData)

        guard let response = xml.response else {
            throw OJPError.unexpectedEmpty
        }
        return response
    }
}
