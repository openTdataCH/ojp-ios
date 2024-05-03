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
    public let requesterReference: String
    public let additionalHeaders: [String: String]?

    /// Configuration for the API
    /// - Parameters:
    ///   - apiEndPoint: the URL that points to the backend API
    ///   - requesterReference: a reference that will be added to the XML repreresenting your client
    ///   - additionalHeaders: some HTTP custom headers. For example to be used for custom authentication when using an API gateway . Example: `["Authorization": "Bearer someToken"]`
    public init(apiEndPoint: URL, requesterReference: String, additionalHeaders: [String: String]? = nil) {
        self.apiEndPoint = apiEndPoint
        self.requesterReference = "\(requesterReference)_\(OJP_SDK_Name)_\(OJP_SDK_Version)"
        self.additionalHeaders = additionalHeaders
    }

    /// TEST environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    public static let test = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-test")!, requesterReference: "OJP_Demo_iOS", additionalHeaders: ["Authorization": "Bearer eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9"])

    /// INT environment.
    /// - Note: this configuration should only be used for demo / testing purposes. It can change frequently
    public static let int = Self(apiEndPoint: URL(string: "https://odpch-api.clients.liip.ch/ojp20-beta")!, requesterReference: "OJP_Demo_iOS", additionalHeaders: ["Authorization": "Bearer eyJvcmciOiI2M2Q4ODhiMDNmZmRmODAwMDEzMDIwODkiLCJpZCI6IjUzYzAyNWI2ZTRhNjQyOTM4NzMxMDRjNTg2ODEzNTYyIiwiaCI6Im11cm11cjEyOCJ9"])
}
