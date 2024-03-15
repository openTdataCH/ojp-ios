//
//  APIConfiguration.swift
//
//
//  Created by Lehnherr Reto on 15.03.2024.
//

import Foundation

/// Defines the access to OJP Service
public struct APIConfiguration {
    public let apiEndPoint: String
    public let authBearerKey: String
    public let additionalHeaders: [(key: String, value: String)]?

    init(apiEndPoint: String, authBearerKey: String, additionalHeaders: [(key: String, value: String)]? = nil) {
        self.apiEndPoint = apiEndPoint
        self.authBearerKey = authBearerKey
        self.additionalHeaders = additionalHeaders
    }

    /// TEST environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let test = Self(apiEndPoint: "https://odpch-api.clients.liip.ch/ojp20-test", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")

    /// INT environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let int = Self(apiEndPoint: "https://odpch-api.clients.liip.ch/ojp20-beta", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")
}
