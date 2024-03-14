// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct OjpSDKConfiguration {
    let baseUrl: String
    let additionalHeaders: [String: String]?
    
    public static var defaultConfig: OjpSDKConfiguration {
        return OjpSDKConfiguration(baseUrl: "https://api.opentransportdata.swiss/ojp2020", additionalHeaders: nil)
    }
}

public class OjpSDK {
    let configuration: OjpSDKConfiguration
    
    public init(configuration: OjpSDKConfiguration = OjpSDKConfiguration.defaultConfig) {
        self.configuration = configuration
    }
    
    public func nearbyStation(from coordinates: (long: Double, lat: Double)) async throws -> Station {
        // create xml for the request
        
        // make the http request
        
        // give back the response
        
        return Station(name: "Test", latitude: 3.4, longitude: 7.6)
    }
    
    public func stations(from searchTerm: String, count: Int) async throws -> [Station] {
        // create xml for the request
        
        // make the http request
        
        // give back the response
        
        return [Station(name: "Test", latitude: 3.4, longitude: 7.6)]
    }
}
