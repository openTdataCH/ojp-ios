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
    public let requestReference: String
    public let accessToken: String?
    public let additionalHeaders: [(key: String, value: String)]?

    public init(apiEndPoint: String, requestorRef: String, authBearerKey: String? = nil, additionalHeaders: [(key: String, value: String)]? = nil) {
        self.apiEndPoint = apiEndPoint
        self.requestReference = "\(requestorRef)_\(OJP_SDK_Version)"
        self.accessToken = authBearerKey
        self.additionalHeaders = additionalHeaders
    }

    /// TEST environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    internal static let test = Self(apiEndPoint: "https://odpch-api.clients.liip.ch/ojp20-test", requestorRef: "OJP_Demo_iOS_\(OJP_SDK_Version)", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")

    /// INT environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    internal static let int = Self(apiEndPoint: "https://odpch-api.clients.liip.ch/ojp20-beta", requestorRef: "OJP_Demo_iOS_\(OJP_SDK_Version)", authBearerKey: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")
}
