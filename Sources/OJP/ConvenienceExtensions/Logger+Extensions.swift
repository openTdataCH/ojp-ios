//
//  Logger+Extensions.swift
//  OJP
//
//  Created by Lehnherr Reto on 09.03.2026.
//

import Foundation
import OSLog

extension Logger {
    static var subsystem: String {
        "swiss.opentransportdata.ojp-sdk"
    }

    static let networkLogging = Logger(subsystem: subsystem, category: "Network")
}
