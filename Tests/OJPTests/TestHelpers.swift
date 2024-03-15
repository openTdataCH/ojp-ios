//
//  TestHelpers.swift
//
//  Temporary Testhelpers
//  Created by Lehnherr Reto on 14.03.2024.
//

import Foundation

enum TestHelpers {
    static func loadXML(xmlFilename: String = "lir-be-bbox") throws -> Data {
        guard let path = Bundle.module.path(forResource: xmlFilename, ofType: "xml") else {
            throw NSError(domain: "Not Found", code: 1)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
}
