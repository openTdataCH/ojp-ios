// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import XMLCoder

public typealias Loader = (Data) async throws -> (Data, URLResponse)

/// Defines the loading strategy. Basically used to switch between HTTP and Mocked-Requests
public enum LoadingStrategy {
    case http(APIConfiguration)
    case mock(Loader)
}

/// Entry point to OJP
public class OJP {
    let loader: Loader
    let locationInformationRequest: OJPHelpers.LocationInformationRequest

    /// Constructor of the OJP class
    /// - Parameter loadingStrategy: Pass a real loader with an API Configuration or a Mock for test purpuse
    public init(loadingStrategy: LoadingStrategy) {
        switch loadingStrategy {
        case let .http(apiConfiguration):
            let httpLoader = HTTPLoader(configuration: apiConfiguration)
            loader = httpLoader.load(request:)
            locationInformationRequest = OJPHelpers.LocationInformationRequest(requesterReference: apiConfiguration.requesterReference)
        case let .mock(loader):
            self.loader = loader
            locationInformationRequest = OJPHelpers.LocationInformationRequest(requesterReference: "Mock_Requestor_Ref")
        }
    }

    static var requestXMLRootAttributes = [
        "xmlns": "http://www.vdv.de/ojp",
        "xmlns:siri": "http://www.siri.org.uk/siri",
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "version": "2.0",
    ]

    private var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    private var decoder: XMLDecoder {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.dateDecodingStrategy = .iso8601
        decoder.shouldProcessNamespaces = true
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    /// Request a list of Locations based on the given geographical point
    /// - Parameter coordinates: a geo point with longitude and latitude
    /// - Returns: List of Locations sorted by the nearest point
    public func requestLocations(from coordinates: Point) async throws -> [NearbyObject<OJPv2.PlaceResult>] {
        let ojp = locationInformationRequest.requestWithBox(centerLongitude: coordinates.long, centerLatitude: coordinates.lat, boxWidth: 1000.0)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        let nearbyObjects = GeoHelpers.sort(geoAwareObjects: locationInformationDelivery.placeResults, from: coordinates)

        return nearbyObjects
    }

    /// Request a list of Locations based on the given search term
    /// - Parameter searchTerm: The given term
    /// - Returns: List of Locations that contains the search term
    public func requestLocations(from searchTerm: String) async throws -> [OJPv2.PlaceResult] {
        let ojp = locationInformationRequest.requestWithSearchTerm(searchTerm)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        return locationInformationDelivery.placeResults
    }

    private func request(with ojp: OJPv2) async throws -> OJPv2.Response {
        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: OJP.requestXMLRootAttributes)
        guard String(data: ojpXMLData, encoding: .utf8) != nil else {
            throw OJPSDKError.encodingFailed
        }

        let (data, response) = try await loader(ojpXMLData)

        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw OJPSDKError.unexpectedHTTPStatus(httpResponse.statusCode)
            }
            do {
                return try OJPDecoder.response(data)
            } catch {
                throw OJPSDKError.decodingFailed(error)
            }
        } else {
            throw OJPSDKError.unexpectedEmpty
        }
    }
}
