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

    public init(loadingStrategy: LoadingStrategy) {
        switch loadingStrategy {
        case let .http(apiConfiguration):
            let httpLoader = HTTPLoader(configuration: apiConfiguration)
            loader = httpLoader.load(request:)
        case let .mock(loader):
            self.loader = loader
        }
    }

    public static var requestXMLRootAttributes = [
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

    public func nearbyStations(from point: Point) async throws -> [NearbyObject<OJPv2.PlaceResult>] {
        let ojp = OJPHelpers.LocationInformationRequest.requestWithBox(centerLongitude: point.long, centerLatitude: point.lat, boxWidth: 500.0)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPError.unexpectedEmpty
        }

        let nearbyObjects = GeoHelpers.sort(geoAwareObjects: locationInformationDelivery.placeResults, from: point)

        return nearbyObjects
    }

    public func stations(by stopName: String, limit: Int = 10) async throws -> [OJPv2.PlaceResult] {
        let ojp = OJPHelpers.LocationInformationRequest.requestWithStopName(stopName);
        
        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .locationInformation(locationInformationDelivery) = serviceDelivery.delivery else {
            throw OJPError.unexpectedEmpty
        }
        
        return locationInformationDelivery.placeResults
    }

    private func request(with ojp: OJPv2) async throws -> OJPv2.Response {
        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: OJP.requestXMLRootAttributes)
        guard String(data: ojpXMLData, encoding: .utf8) != nil else {
            throw OJPError.encodingFailed
        }

        let (data, response) = try await loader(ojpXMLData)

        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw OJPError.unexpectedHTTPStatus(httpResponse.statusCode)
            }
            return try OJPDecoder.response(data)
        } else {
            throw OJPError.unexpectedEmpty
        }
    }
}
