// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct OjpSDKConfiguration {
    public let APIToken: String
    public let baseURL: String
    public let additionalHeaders: [(key: String, value: String)]?
    public let loadingStragegy: LoadingStrategy

    public init(APIToken: String, baseURL: String, additionalHeaders: [(key: String, value: String)]? = nil, loadingStragegy: LoadingStrategy) {
        self.APIToken = APIToken
        self.baseURL = baseURL
        self.additionalHeaders = additionalHeaders
        self.loadingStragegy = loadingStragegy
    }
}


public typealias Loader = (Data) async throws -> (Data, URLResponse)

public enum LoadingStrategy {
    case http
    case mock(Loader)
}

public class OJP {
    let configuration: OjpSDKConfiguration
    let loader: Loader

    public init(configuration: OjpSDKConfiguration) {
        self.configuration = configuration

        switch configuration.loadingStragegy {
        case .http:
            let httpLoader = HTTPLoader(configuration: configuration)
            loader = httpLoader.load(request:)
        case .mock(let loader):
            self.loader = loader
        }
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
