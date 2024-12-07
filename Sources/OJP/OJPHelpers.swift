//
//  OJPHelpers.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation
import XMLCoder

extension Double {
    /// Rounds the double to `decimalPlaces` decimal places.
    /// - Parameter decimalPlaces: The number of decimal places to round to.
    /// - Returns: The rounded number.
    func rounded(to decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
}

public enum DepArrTime: Codable, Sendable {
    case departure(Date)
    case arrival(Date)
}

enum OJPHelpers {
    struct RequestConfiguration: Sendable {
        let requestContext: OJPv2.ServiceRequestContext
        let requesterReference: String

        init(requestContext: OJPv2.ServiceRequestContext, requesterReference: String) {
            self.requestContext = requestContext
            self.requesterReference = requesterReference
        }

        init(language: String, requesterReference: String) {
            self.init(requestContext: .init(language: language), requesterReference: requesterReference)
        }
    }

    struct TripRequest: Sendable {
        init(_ configuration: RequestConfiguration) {
            requestContext = configuration.requestContext
            requesterReference = configuration.requesterReference
        }

        let requestContext: OJPv2.ServiceRequestContext
        let requesterReference: String

        public func requestTrips(from: OJPv2.PlaceRefChoice, to: OJPv2.PlaceRefChoice, via: [OJPv2.PlaceRefChoice]?, at: DepArrTime, params: OJPv2.TripParams) -> OJPv2 {
            let requestTimestamp = Date()
            let origin: OJPv2.PlaceContext
            let destination: OJPv2.PlaceContext
            var vias: [OJPv2.TripVia] = []

            switch at {
            case let .departure(date):
                origin = OJPv2.PlaceContext(placeRef: from, depArrTime: date)
                destination = OJPv2.PlaceContext(placeRef: to, depArrTime: nil)
            case let .arrival(date):
                origin = OJPv2.PlaceContext(placeRef: from, depArrTime: nil)
                destination = OJPv2.PlaceContext(placeRef: to, depArrTime: date)
            }

            if let via {
                for v in via {
                    vias.append(OJPv2.TripVia(viaPoint: v))
                }
            }

            let tripRequest = OJPv2.TripRequest(requestTimestamp: requestTimestamp, origin: origin, destination: destination, via: vias, params: params)

            let ojp = OJPv2(
                request: OJPv2.Request(
                    serviceRequest: OJPv2.ServiceRequest(
                        requestContext: requestContext,
                        requestTimestamp: requestTimestamp,
                        requestorRef: requesterReference,
                        locationInformationRequest: nil,
                        tripRequest: tripRequest
                    )
                ), response: nil
            )

            return ojp
        }
    }

    struct StopEventRequest: Sendable {
        init(_ configuration: RequestConfiguration) {
            requestContext = configuration.requestContext
            requesterReference = configuration.requesterReference
        }

        let requestContext: OJPv2.ServiceRequestContext
        let requesterReference: String

        public func requestStopEvents(location: OJPv2.PlaceContext, params: OJPv2.StopEventParam?) -> OJPv2 {
            let requestTimestamp = Date()

            let stopEventRequest = OJPv2.StopEventRequest(
                requestTimestamp: requestTimestamp,
                location: location,
                params: params
            )

            let ojp = OJPv2(
                request: OJPv2.Request(
                    serviceRequest: OJPv2.ServiceRequest(
                        requestContext: requestContext,
                        requestTimestamp: requestTimestamp,
                        requestorRef: requesterReference,
                        stopEventRequest: stopEventRequest
                    )
                ), response: nil
            )

            return ojp
        }
    }

    struct LocationInformationRequest: Sendable {
        let requestContext: OJPv2.ServiceRequestContext
        let requesterReference: String

        init(_ configuration: RequestConfiguration) {
            requestContext = configuration.requestContext
            requesterReference = configuration.requesterReference
        }

        /// Creates a new OJP LocationInformationRequest with bounding box
        /// - Parameters
        ///   - bbox: Bounding box used as ``OJPv2/GeoRestriction``
        ///   - limit: results limit
        /// - Returns: OJPv2 containing a request
        public func requestWith(bbox: Geo.Bbox, numberOfResults: Int = 10) -> OJPv2 {
            let requestTimestamp = Date()

            let upperLeft = OJPv2.GeoPosition(longitude: bbox.minX, latitude: bbox.maxY)
            let lowerRight = OJPv2.GeoPosition(longitude: bbox.maxX, latitude: bbox.minY)
            let rectangle = OJPv2.Rectangle(upperLeft: upperLeft, lowerRight: lowerRight)
            let geoRestriction = OJPv2.GeoRestriction(rectangle: rectangle)
            let restrictions = OJPv2.PlaceParam(type: [.stop], numberOfResults: numberOfResults, includePtModes: true)

            let locationInformationRequest = OJPv2.LocationInformationRequest(
                requestTimestamp: requestTimestamp,
                input: .initialInput(
                    OJPv2.InitialInput(
                        geoRestriction: geoRestriction,
                        name: nil
                    )
                ),
                restrictions: restrictions
            )

            let ojp = OJPv2(request:
                OJPv2.Request(
                    serviceRequest: OJPv2.ServiceRequest(
                        requestContext: requestContext,
                        requestTimestamp: requestTimestamp,
                        requestorRef: requesterReference,
                        locationInformationRequest: locationInformationRequest,
                        tripRequest: nil
                    )
                ),
                response: nil)

            return ojp
        }

        public func request(with placeRef: OJPv2.PlaceRefChoice, restrictions: OJPv2.PlaceParam) -> OJPv2 {
            let lir = OJPv2.LocationInformationRequest(
                requestTimestamp: Date(),
                input: .placeRef(placeRef),
                restrictions: restrictions
            )
            return OJPv2(
                request: OJPv2.Request(
                    serviceRequest: OJPv2.ServiceRequest(
                        requestContext: requestContext,
                        requestTimestamp: Date(),
                        requestorRef: requesterReference,
                        locationInformationRequest: lir,
                        tripRequest: nil
                    )
                ),
                response: nil
            )
        }

        /// Creates a new OJP LocationInformationRequest with bounding box around a center coordinate.
        /// - Parameters:
        ///   - centerLongitude: center of the bounding box
        ///   - centerLatitude: center of the bounding box
        ///   - boxWidth: bounding box width in meters
        ///   - boxHeight: bounding box  height in meters
        ///   - limit: results limit
        /// - Returns: OJPv2 containing a request
        public func requestWithBox(centerLongitude: Double, centerLatitude: Double, boxWidth: Double, boxHeight: Double? = nil, numberOfResults: Int = 10) -> OJPv2 {
            let boxHeight = boxHeight ?? boxWidth

            let point2Longitude = centerLongitude + 1
            let point2Latitude = centerLatitude + 1

            // Calculate length of a degree of longitude / latitude in meters
            let degreeLongitudeDistance = GeoHelpers.calculateDistance(lon1: centerLongitude, lat1: centerLatitude, lon2: point2Longitude, lat2: centerLatitude)
            let degreeLatitudeDistance = GeoHelpers.calculateDistance(lon1: centerLongitude, lat1: centerLatitude, lon2: centerLongitude, lat2: point2Latitude)

            // Then use direct proportionality to calculate box longitude / latitude delta
            let ratioLongitude = boxWidth / degreeLongitudeDistance
            let ratioLatitude = boxHeight / degreeLatitudeDistance

            let minLongitude = (centerLongitude - ratioLongitude / 2).rounded(to: 6)
            let minLatitude = (centerLatitude - ratioLatitude / 2).rounded(to: 6)
            let maxLongitude = (centerLongitude + ratioLongitude / 2).rounded(to: 6)
            let maxLatitude = (centerLatitude + ratioLatitude / 2).rounded(to: 6)

            let bbox = Geo.Bbox(minLongitude: minLongitude, minLatitude: minLatitude, maxLongitude: maxLongitude, maxLatitude: maxLatitude)

            let ojp = requestWith(bbox: bbox, numberOfResults: numberOfResults)

            return ojp
        }

        /// Creates a new OJP LocationInformationRequest with a search term
        /// - Parameters:
        ///   - name: search term (the name of a stop)
        ///   - limit: results limit
        /// - Returns: OJPv2 containing a request
        public func requestWithSearchTerm(_ name: String, restrictions: OJPv2.PlaceParam) -> OJPv2 {
            let requestTimestamp = Date()

            let locationInformationRequest = OJPv2.LocationInformationRequest(requestTimestamp: requestTimestamp, input: .initialInput(OJPv2.InitialInput(geoRestriction: nil, name: name)), restrictions: restrictions)

            // TODO: - avoid duplication (share this block with "requestWith(bbox: Geo.Bbox")
            let ojp = OJPv2(request: OJPv2.Request(
                serviceRequest: OJPv2.ServiceRequest(
                    requestContext: requestContext,
                    requestTimestamp: requestTimestamp,
                    requestorRef: requesterReference,
                    locationInformationRequest: locationInformationRequest
                )
            ),
            response: nil)

            return ojp
        }
    }

    struct TripInfoRequest: Sendable {
        let requestContext: OJPv2.ServiceRequestContext
        let requesterReference: String

        init(_ configuration: RequestConfiguration) {
            requestContext = configuration.requestContext
            requesterReference = configuration.requesterReference
        }

        public func request(_ journeyRef: String, operatingDayRef: String, params: OJPv2.TripInfoParam) -> OJPv2 {
            let requestTimestamp = Date()

            let tripInfoRequest = OJPv2.TripInfoRequest(journeyRef: journeyRef, operatingDayRef: operatingDayRef, params: params)

            // TODO: - avoid duplication (share this block with "requestWith(bbox: Geo.Bbox")
            let ojp = OJPv2(request: OJPv2.Request(
                serviceRequest: OJPv2.ServiceRequest(
                    requestContext: requestContext,
                    requestTimestamp: requestTimestamp,
                    requestorRef: requesterReference,
                    tripInfoRequest: tripInfoRequest
                )
            ),
            response: nil)

            return ojp
        }
    }

    // TODO: remove this method ?
    static func buildXMLRequest(ojpRequest: OJPv2) throws -> String {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let ojpXMLData = try encoder.encode(ojpRequest, withRootKey: "OJP", rootAttributes: requestXMLRootAttributes)
        guard let ojpXML = String(data: ojpXMLData, encoding: .utf8) else {
            throw OJPSDKError.encodingFailed
        }

        return ojpXML
    }
}
