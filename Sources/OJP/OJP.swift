// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import XMLCoder

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

    private var requestXMLRootAttributes = [
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

    public func nearbyStations(from point: (long: Double, lat: Double)) async throws -> [OJPv2.PlaceResult] {
        let ojp = OJPHelpers.LocationInformationRequest.initWithBoxCoordsWidthHeight(centerLongitude: point.long, centerLatitude: point.lat, boxWidth: 500.0)

        let placeResults = try await request(with: ojp).serviceDelivery.locationInformationDelivery.placeResults

        return OJPHelpers.LocationInformationRequest.placeResultsSorted(from: point, placeResults: placeResults)
    }

    public func stations(from _: String, count _: Int) async throws -> [OJPv2.PlaceResult] {
        // create xml for the request

        // make the http request

        // give back the response

        throw NSError(domain: "not implemented", code: 1)
    }

    private func request(with ojp: OJPv2) async throws -> OJPv2.Response {
        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: requestXMLRootAttributes)
        guard String(data: ojpXMLData, encoding: .utf8) != nil else {
            throw NSError(domain: "can't encode String", code: 1)
        }

        let (data, response) = try await loader(ojpXMLData)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                return try parseXMLStrippingNamespace(data)
            } else {
                throw NSError(domain: "status code \(httpResponse.statusCode)", code: 1)
            }
        } else {
            throw NSError(domain: "no httpResponse", code: 1)
        }
    }

    private func parseXMLStrippingNamespace(_ xmlData: Data) throws -> OJPv2.Response {
        if let xmlString = String(data: xmlData, encoding: .utf8) {
            if let utf16Data = xmlString.data(using: .utf16) { // TODO: remove this after utf16
                let ojp = try decoder.decode(OJPv2.self, from: utf16Data)
                if let response = ojp.response {
                    return response
                } else {
                    throw NSError(domain: "response object not found", code: 1)
                }
            }
        }
        throw NSError(domain: "parsing error", code: 1)
    }
}
