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
    let tripInfoRequest: OJPHelpers.TripInfoRequest
    let stopEventRequest: OJPHelpers.StopEventRequest
    let tripRefineRequest: OJPHelpers.TripRefineRequest

    /// Constructor of the OJP class
    /// - Parameter loadingStrategy: Pass a real loader with an API Configuration or a Mock for test purpuse
    /// - Parameter language: ISO language code. Defaults to the first current preferred localization according to the bundle.
    public init(
        loadingStrategy: LoadingStrategy,
        language: String = Bundle.main.preferredLocalizations.first ?? "de"
    ) {
        let requestConfiguration: OJPHelpers.RequestConfiguration

        switch loadingStrategy {
        case let .http(apiConfiguration):
            let httpLoader = HTTPLoader(configuration: apiConfiguration)
            loader = httpLoader.load(request:)
            requestConfiguration = .init(
                language: language,
                requesterReference: apiConfiguration.requesterReference
            )
        case let .mock(loader):
            self.loader = loader
            requestConfiguration = .init(language: language, requesterReference: "Mock_Requestor_Ref")
        }

        locationInformationRequest = .init(requestConfiguration)
        tripRequest = .init(requestConfiguration)
        tripInfoRequest = .init(requestConfiguration)
        stopEventRequest = .init(requestConfiguration)
        tripRefineRequest = .init(requestConfiguration)
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

    public func requestTrips(
        from: OJPv2.PlaceRefChoice,
        to: OJPv2.PlaceRefChoice,
        via: [OJPv2.PlaceRefChoice]? = nil,
        at: DepArrTime = .departure(Date()),
        params: OJPv2.TripParams
    ) async throws -> OJPv2.TripDelivery {
        let ojp = tripRequest.requestTrips(from: from, to: to, via: via, at: at, params: params)

        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .trip(tripDelivery) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }

        return tripDelivery
    }

    public func requestTripInfo(
        journeyRef: String,
        operatingDayRef: String,
        params: OJPv2.TripInfoParam = .init()
    ) async throws -> OJPv2.TripInfoDelivery {
        let ojp = tripInfoRequest.request(journeyRef, operatingDayRef: operatingDayRef, params: params)
        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .tripInfo(tripInfo) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }
        return tripInfo
    }

    /// Request an updated Trip from an existing Trip
    /// - Parameter tripResult: the existing TripResult you got before
    /// - Parameter useMinimalRequest: the request not need all fields of the Trip objekt, so the SDK just send the minimal necessary fields, you can disable this by setting useMinimalRequest to false if you need all fields
    /// - Parameter refineParams: the parameters for the request
    /// - Returns: The TripRefineDelivery for the Trip that you need
    public func requestTripRefinement(
        tripResult: OJPv2.TripResult,
        useMinimalRequest: Bool = true,
        refineParams: OJPv2.TripRefineParams = .defaultTripRefineParams
    ) async throws -> OJPv2.TripRefineDelivery {
        let ojp = tripRefineRequest.refineTrip(useMinimalRequest ? tripResult.minimalTripResult : tripResult, refineParams: refineParams)
        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .tripRefinement(tripRefinement) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }
        return tripRefinement
    }

    public func requestStopEvent(
        location: OJPv2.PlaceContext,
        params: OJPv2.StopEventParam?
    ) async throws -> OJPv2.StopEventDelivery {
        let ojp = stopEventRequest.requestStopEvents(location: location, params: params)
        let serviceDelivery = try await request(with: ojp).serviceDelivery

        guard case let .stopEvent(stopEvent) = serviceDelivery.delivery else {
            throw OJPSDKError.unexpectedEmpty
        }
        return stopEvent
    }

    func request(with ojp: OJPv2) async throws -> OJPv2.Response {
        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: requestXMLRootAttributes)
        guard let xmlString = String(data: ojpXMLData, encoding: .utf8) else {
            throw OJPSDKError.encodingFailed
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await loader(ojpXMLData)
            debugPrint("--- Request ----")
            debugPrint(xmlString)
            if let _ = response as? HTTPURLResponse {
                debugPrint("--- Response ----")
                if let xmlResponse = String(data: data, encoding: .utf8) {
                    debugPrint(xmlResponse)
                }
                debugPrint("---")
            }
        } catch let error as URLError {
            throw OJPSDKError.loadingFailed(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw OJPSDKError.unexpectedHTTPStatus(httpResponse.statusCode)
            }
            return try await OJPDecoder.response(data)
        } else {
            throw OJPSDKError.unexpectedEmpty
        }
    }
}
