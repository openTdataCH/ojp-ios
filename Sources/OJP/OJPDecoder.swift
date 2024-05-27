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
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .custom { codingPath in
            guard let codingPath = codingPath.last else { fatalError() }
            return StrippedPrefixCodingKey.stripPrefix(fromKey: codingPath)
        }
        do {
            return try decoder.decode(T.self, from: xmlData)
        } catch {
            throw OJPSDKError.decodingFailed(error)
        }
    }

    static func parseXML(_ xmlData: Data) throws -> OJPv2 {
        try parseXML(OJPv2.self, xmlData)
    }

    static func response(_ xmlData: Data) throws -> OJPv2.Response {
        let xml = try parseXML(xmlData)
        guard let response = xml.response else {
            throw OJPSDKError.unexpectedEmpty
        }
        return response
    }
}
