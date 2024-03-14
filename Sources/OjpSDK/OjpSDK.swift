// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct OjpSDKConfiguration {
    public let APIToken: String
    public let baseURL: String
    public let additionalHeaders: [(key: String, value: String)]?

    public init(APIToken: String, baseURL: String, additionalHeaders: [(key: String, value: String)]? = nil) {
        self.APIToken = APIToken
        self.baseURL = baseURL
        self.additionalHeaders = additionalHeaders
    }
}

public class OjpSDK {
    let configuration: OjpSDKConfiguration
    let loader: HTTPLoader

    public init(configuration: OjpSDKConfiguration) {
        self.configuration = configuration
        self.loader = HTTPLoader(configuration: configuration)
    }

    public func nearbyStation(from _: (long: Double, lat: Double)) async throws -> Station {
        // create xml for the request

        // make the http request

        // give back the response

        return Station(name: "Test", latitude: 3.4, longitude: 7.6)
    }

    public func stations(from _: String, count _: Int) async throws -> [Station] {
        // create xml for the request

        // make the http request

        // give back the response

        return [Station(name: "Test", latitude: 3.4, longitude: 7.6)]
    }
}
