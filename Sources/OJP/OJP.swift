// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import XMLCoder

public typealias Loader = @Sendable (Data) async throws -> (Data, URLResponse)

/// Defines the loading strategy. Basically used to switch between HTTP and Mocked-Requests
public enum LoadingStrategy {
    case http(APIConfiguration)
    case mock(Loader)
}

// TODO: - find me a better place
public enum PlaceType: String, Codable, Sendable {
    case stop
    case address
}

let requestXMLRootAttributes = [
    "xmlns": "http://www.vdv.de/ojp",
    "xmlns:siri": "http://www.siri.org.uk/siri",
    "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
    "version": "2.0",
]

/// Entry point to OJP
public final class OJP: Sendable {
    let loader: Loader
    let locationInformationRequest: OJPHelpers.LocationInformationRequest
    let tripRequest: OJPHelpers.TripRequest

    /// Constructor of the OJP class
    /// - Parameter loadingStrategy: Pass a real loader with an API Configuration or a Mock for test purpuse
    public init(loadingStrategy: LoadingStrategy) {
        switch loadingStrategy {
        case let .http(apiConfiguration):
            let httpLoader = HTTPLoader(configuration: apiConfiguration)
            loader = httpLoader.load(request:)
            locationInformationRequest = OJPHelpers.LocationInformationRequest(requesterReference: apiConfiguration.requesterReference)
            tripRequest = OJPHelpers.TripRequest(requesterReference: apiConfiguration.requesterReference)
        case let .mock(loader):
            self.loader = loader
            locationInformationRequest = OJPHelpers.LocationInformationRequest(requesterReference: "Mock_Requestor_Ref")
            tripRequest = OJPHelpers.TripRequest(requesterReference: "Mock_Requestor_Ref")
        }
    }

    private var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    /// Request a list of PlaceResults based on the given geographical point
    /// - Parameter coordinates: a geo point with longitude and latitude
    /// - Returns: List of PlaceResults sorted by the nearest point
    public func requestPlaceResults(from coordinates: Point) async throws -> [NearbyObject<OJPv2.PlaceResult>] {
        let ojp = locationInformationRequest.requestWithBox(centerLongitude: coordinates.long, centerLatitude: coordinates.lat, boxWidth: 1000.0)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        let nearbyObjects = GeoHelpers.sort(geoAwareObjects: locationInformationDelivery.placeResults, from: coordinates)
        return nearbyObjects
    }

    /// Request a list of PlaceResults based on the given search term
    /// - Parameter searchTerm: The given term
    /// - Parameter restrictions: filter with a place param
    /// - Returns: List of PlaceResults that contains the search term
    public func requestPlaceResults(from searchTerm: String, restrictions: OJPv2.PlaceParam) async throws -> [OJPv2.PlaceResult] {
        let ojp = locationInformationRequest.requestWithSearchTerm(searchTerm, restrictions: restrictions)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        return locationInformationDelivery.placeResults
    }

    public func requestPlaceResults(placeRef: OJPv2.PlaceRefChoice, restrictions: OJPv2.PlaceParam) async throws -> [OJPv2.PlaceResult] {
        let ojp = locationInformationRequest.request(with: placeRef, restrictions: restrictions)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        return locationInformationDelivery.placeResults
    }

    public func requestTrips(from: OJPv2.PlaceRefChoice, to: OJPv2.PlaceRefChoice, via: [OJPv2.PlaceRefChoice]? = nil, at: DepArrTime = .departure(Date()), params: OJPv2.TripParams) async throws -> OJPv2.TripDelivery {
        let ojp = tripRequest.requestTrips(from: from, to: to, via: via, at: at, params: params)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .trip(tripDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        return tripDelivery
    }

    func request(with ojp: OJPv2) async throws -> OJPv2.Response {
        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: requestXMLRootAttributes)
        guard let xmlString = String(data: ojpXMLData, encoding: .utf8) else {
            throw OJPSDKError.encodingFailed
        }

        debugPrint(xmlString)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await loader(ojpXMLData)
        } catch let error as URLError {
            throw OJPSDKError.loadingFailed(error)
        }

        if let ojpXMLResponse = String(data: data, encoding: .utf8) {
            debugPrint("Response Body:")
            debugPrint(ojpXMLResponse)
        }

        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw OJPSDKError.unexpectedHTTPStatus(httpResponse.statusCode)
            }
            return try OJPDecoder.response(data)
        } else {
            throw OJPSDKError.unexpectedEmpty
        }
    }
}
