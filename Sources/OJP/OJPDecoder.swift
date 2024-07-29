//
//  OJPDecoder.swift
//
//
//  Created by Lehnherr Reto on 18.03.2024.
//

import Foundation
import XMLCoder

@globalActor actor DecoderActor: GlobalActor {
    static let shared = DecoderActor()
}

@DecoderActor
private var ojpNameSpace = ""
@DecoderActor
private var siriNameSpace = ""
@DecoderActor
private var keyMapping: [String: String] = [:] // ["no-namespace" : "resolved according to CodingKeys"]

struct NamespaceAwareCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }

    static func create(from keys: [CodingKey], ojpNS: String, siriNS: String, mapping: inout [String: String]) -> NamespaceAwareCodingKey {
        let strippedKeys = keys.map { key in removeNameSpace(key.stringValue) }
        let lookupKey = strippedKeys
            .filter({ Int($0) == nil }) // ignore positional keys
            .joined(separator: "/")

        // the mapping is needed, as the keyDecodingStrategy could be performed on a already converted key, leading to an invalid new key.
        // as elements could turn up both in siri and ojp namespace, we need the whole list of coding keys. See https://github.com/openTdataCH/ojp-ios/issues/56
        if let existing = mapping[lookupKey] {
            return NamespaceAwareCodingKey(stringValue: existing)!
        }
        let key = keys.last!
        let strippedKey = removeNameSpace(key.stringValue)
        if ojpNS.isEmpty && siriNS.isEmpty || key.stringValue.contains("xmlns") {
            // ignore root elements
            return NamespaceAwareCodingKey(stringValue: strippedKey)!
        }

        if !ojpNS.isEmpty, key.stringValue.contains(ojpNS) {
            // removes a potential "ojp" namespace to match the the type's CodingKeys
            mapping[lookupKey] = strippedKey
            return NamespaceAwareCodingKey(stringValue: removeNameSpace(key.stringValue))!
        }
        if siriNS.isEmpty, !key.stringValue.contains(ojpNS) {
            // adds 'siri:' if it isn't present in the source to match the type's CodingKeys
            mapping[lookupKey] = "siri:\(key.stringValue)"
            return NamespaceAwareCodingKey(stringValue: "siri:\(key.stringValue)")!
        }

        // keep stringValue as it is
        mapping[lookupKey] = "\(key.stringValue)"
        return NamespaceAwareCodingKey(stringValue: key.stringValue)!
    }

    static func removeNameSpace(_ string: String) -> String {
        String(string.split(separator: ":").last!)
    }
}

@DecoderActor
enum OJPDecoder {
    static func parseXML<T: Decodable>(_: T.Type, _ xmlData: Data) throws -> T {
        let decoder = XMLDecoder()

        siriNameSpace = ""
        ojpNameSpace = ""
        keyMapping = [:]

        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .custom { codingPath in
            guard let codingPathLast = codingPath.last else { fatalError() }
            // This is a very naive approach to check the used namespaces. Maybe implement a more robust one in the future.
            if codingPathLast.stringValue.contains("xmlns:ojp") {
                ojpNameSpace = "ojp:"
            } else if codingPathLast.stringValue.contains("xmlns:siri") {
                siriNameSpace = "siri:"
            }

            return NamespaceAwareCodingKey.create(from: codingPath, ojpNS: ojpNameSpace, siriNS: siriNameSpace, mapping: &keyMapping)
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
