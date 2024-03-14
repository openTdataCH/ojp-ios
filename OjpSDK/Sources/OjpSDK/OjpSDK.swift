// The Swift Programming Language
// https://docs.swift.org/swift-book



import Foundation


public class OjpSDK {
    
    public static let ojpBaseUrl = "https://api.opentransportdata.swiss/ojp2020"
    
    let baseUrl: String
    let customHttpHeaders: [String: String]?
    
    public init(baseUrl: String = OjpSDK.ojpBaseUrl, customHttpHeaders: [String: String]? = nil) {
        self.baseUrl = baseUrl
        self.customHttpHeaders = customHttpHeaders
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
