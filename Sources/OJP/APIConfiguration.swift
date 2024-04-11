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
    public let authBearerToken: String?
    public let additionalHeaders: [(key: String, value: String)]?

    /// Configuration for the API
    /// - Parameters:
    ///   - apiEndPoint: the URL that points to the backend API
    ///   - requestReference: a reference that will be added to the XML repreresenting your client
    ///   - authBearerToken: a Bearer token, it's send in this manner: Authorization: Bearer <your token>
    ///   - additionalHeaders: some HTTP custom headers
    public init(apiEndPoint: URL, requestReference: String, authBearerToken: String? = nil, additionalHeaders: [(key: String, value: String)]? = nil) {
        self.apiEndPoint = apiEndPoint
        self.requestReference = "\(requestReference)_\(OJP_SDK_Name)_\(OJP_SDK_Version)"
        self.authBearerToken = authBearerToken
        self.additionalHeaders = additionalHeaders
    }

    /// TEST environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let test = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-test")!, requestReference: "OJP_Demo_iOS", authBearerToken: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")

    /// INT environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    static let int = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-beta")!, requestReference: "OJP_Demo_iOS", authBearerToken: "eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9")
}
