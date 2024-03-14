//
//  ojp_helpers.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation

class OJPHelpers {
    public static func FormattedDate(date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // ISO 8601 format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone to UTC

        let dateF = dateFormatter.string(from: date)
        return dateF
    }
    
    class LocationInformationRequest {
        public static func initWithBBOX(bbox: Geo.Bbox) -> OJP {
            let upperLeft = OJP.GeoPosition(longitude: bbox.minX, latitude: bbox.maxY)
            let lowerRight = OJP.GeoPosition(longitude: bbox.maxX, latitude: bbox.minY)
            let rectangle = OJP.Rectangle(upperLeft: upperLeft, lowerRight: lowerRight)
            let geoRestriction = OJP.GeoRestriction(rectangle: rectangle)
            let locationInformationRequest = OJP.LocationInformationRequest(initialInput: OJP.InitialInput(geoRestriction: geoRestriction))
            
            let requestTimestamp = OJPHelpers.FormattedDate()
            let requestorRef = "OJP_Demo_iOS_\(OJP_SDK_Version)"
            let ojp = OJP(request: OJP.Request(serviceRequest: OJP.ServiceRequest(locationInformationRequest: locationInformationRequest, requestTimestamp: requestTimestamp, requestorRef: requestorRef)), response: nil)
            
            return ojp
        }
    }
}
