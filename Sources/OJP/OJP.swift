// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public typealias Loader = (Data) async throws -> (Data, URLResponse)

public enum LoadingStrategy {
    case http(APIConfiguration)
    case mock(Loader)
}

public class OJP {
    let loader: Loader

    public init(loadingStrategy: LoadingStrategy) {
        switch loadingStrategy {
        case let .http(apiConfiguration):
            let httpLoader = HTTPLoader(configuration: apiConfiguration)
            loader = httpLoader.load(request:)
        case let .mock(loader):
            self.loader = loader
        }
    }

    public func nearbyStation(from _: (long: Double, lat: Double)) async throws -> Station {
        // create xml for the request

        // make the http request

        // give back the response

        Station(name: "Test", latitude: 3.4, longitude: 7.6)
    }

    public func stations(from _: String, count _: Int) async throws -> [Station] {
        // create xml for the request

        // make the http request

        // give back the response

        [Station(name: "Test", latitude: 3.4, longitude: 7.6)]
    }
}
