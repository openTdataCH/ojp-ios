//
//  APIConfiguration.swift
//
//
//  Created by Lehnherr Reto on 15.03.2024.
//

import Foundation

/// Defines the access to OJP Service
public struct APIConfiguration {
    public let apiEndPoint: URL
    public let requestReference: String
    public let accessToken: String?
    public let additionalHeaders: [(key: String, value: String)]?

    public init(apiEndPoint: URL, requestReference: String, authBearerKey: String? = nil, additionalHeaders: [(key: String, value: String)]? = nil) {
        self.apiEndPoint = apiEndPoint
        self.requestReference = "\(requestReference)_\(OJP_SDK_Version)"
        accessToken = authBearerKey
        self.additionalHeaders = additionalHeaders
    }

    /// TEST environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let test = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-test")!, requestReference: "OJP_Demo_iOS", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")

    /// INT environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let int = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-beta")!, requestReference: "OJP_Demo_iOS", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")
}
