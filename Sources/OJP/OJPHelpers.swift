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

enum OJPHelpers {
    static func formattedDate(date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // ISO 8601 format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone to UTC

        let dateF = dateFormatter.string(from: date)
        return dateF
    }

    class LocationInformationRequest {
        
        init(requestorRef: String) {
            self.requestorRef = requestorRef
        }
        
        let requestorRef: String
        
        /// Creates a new OJP LocationInformationRequest with bounding box
        /// - Parameters
        ///   - bbox: Bounding box used as ``OJPv2/GeoRestriction``
        ///   - limit: results limit
        /// - Returns: OJPv2 containing a request
        public func requestWith(bbox: Geo.Bbox, numberOfResults: Int = 10) -> OJPv2 {
            let requestTimestamp = OJPHelpers.formattedDate()

            let upperLeft = OJPv2.GeoPosition(longitude: bbox.minX, latitude: bbox.maxY)
            let lowerRight = OJPv2.GeoPosition(longitude: bbox.maxX, latitude: bbox.minY)
            let rectangle = OJPv2.Rectangle(upperLeft: upperLeft, lowerRight: lowerRight)
            let geoRestriction = OJPv2.GeoRestriction(rectangle: rectangle)
            let restrictions = OJPv2.Restrictions(type: "stop", numberOfResults: numberOfResults, includePtModes: true)

            let locationInformationRequest = OJPv2.LocationInformationRequest(requestTimestamp: requestTimestamp, initialInput: OJPv2.InitialInput(geoRestriction: geoRestriction, name: nil), restrictions: restrictions)

            let ojp = OJPv2(request: OJPv2.Request(serviceRequest: OJPv2.ServiceRequest(requestTimestamp: requestTimestamp, requestorRef: requestorRef, locationInformationRequest: locationInformationRequest)), response: nil)

            return ojp
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
        
        /// Creates a new OJP LocationInformationRequest with stop name
        /// - Parameters:
        ///   - name: stop name
        ///   - limit: results limit
        /// - Returns: OJPv2 containing a request
        public func requestWithStopName(_ name: String, numberOfResults: Int = 10) -> OJPv2 {
            let requestTimestamp = OJPHelpers.formattedDate()
            let restrictions = OJPv2.Restrictions(type: "stop", numberOfResults: numberOfResults, includePtModes: true)
            
            let locationInformationRequest = OJPv2.LocationInformationRequest(requestTimestamp: requestTimestamp, initialInput: OJPv2.InitialInput(geoRestriction: nil, name: name), restrictions: restrictions)
            
            // TODO - avoid duplication (share this block with "requestWith(bbox: Geo.Bbox")
            let ojp = OJPv2(request: OJPv2.Request(serviceRequest: OJPv2.ServiceRequest(requestTimestamp: requestTimestamp, requestorRef: requestorRef, locationInformationRequest: locationInformationRequest)), response: nil)

            return ojp
        }
    }

    // TODO: remove this method ?
    static func buildXMLRequest(ojpRequest: OJPv2) throws -> String {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let ojpXMLData = try encoder.encode(ojpRequest, withRootKey: "OJP", rootAttributes: OJP.requestXMLRootAttributes)
        guard let ojpXML = String(data: ojpXMLData, encoding: .utf8) else {
            throw OJPError.encodingFailed
        }

        print(ojpXML)
        return ojpXML
    }
}
