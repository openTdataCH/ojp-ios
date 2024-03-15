//
//  OJPHelpers.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation
import XMLCoder

enum OJPHelpers {
    public static func FormattedDate(date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // ISO 8601 format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone to UTC

        let dateF = dateFormatter.string(from: date)
        return dateF
    }

    class LocationInformationRequest {
        public static func initWithBBOX(bbox: Geo.Bbox) -> OJPv2 {
            let requestTimestamp = OJPHelpers.FormattedDate()
            
            let upperLeft = OJPv2.GeoPosition(longitude: bbox.minX, latitude: bbox.maxY)
            let lowerRight = OJPv2.GeoPosition(longitude: bbox.maxX, latitude: bbox.minY)
            let rectangle = OJPv2.Rectangle(upperLeft: upperLeft, lowerRight: lowerRight)
            let geoRestriction = OJPv2.GeoRestriction(rectangle: rectangle)
            let restrictions = OJPv2.Restrictions(type: "stop", numberOfResults: 10, includePtModes: true)
            
            let locationInformationRequest = OJPv2.LocationInformationRequest(requestTimestamp: requestTimestamp, initialInput: OJPv2.InitialInput(geoRestriction: geoRestriction), restrictions: restrictions)

            let requestorRef = "OJP_Demo_iOS_\(OJP_SDK_Version)"
            let ojp = OJPv2(request: OJPv2.Request(serviceRequest: OJPv2.ServiceRequest(requestTimestamp: requestTimestamp, requestorRef: requestorRef, locationInformationRequest: locationInformationRequest)), response: nil)

            return ojp
        }
    }

    static func buildXMLRequest() throws -> String {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojp = OJPHelpers.LocationInformationRequest.initWithBBOX(bbox: bbox)
        
        // TODO - move them in SDK?
        let requestXMLRootAttributes = [
            "xmlns": "http://www.vdv.de/ojp",
            "xmlns:siri": "http://www.siri.org.uk/siri",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "version": "2.0",
        ]
        
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let ojpXMLData = try encoder.encode(ojp, withRootKey: "OJP", rootAttributes: requestXMLRootAttributes)
        guard let ojpXML = String(data: ojpXMLData, encoding: .utf8) else {
            throw NSError(domain: "can't encode String", code: 1)
        }

        print(ojpXML)
        return ojpXML
    }

    static func parseXMLStrippingNamespace(_ xmlData: Data) throws -> OJPv2.LocationInformationDelivery {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.dateDecodingStrategy = .iso8601
        decoder.shouldProcessNamespaces = true
        decoder.keyDecodingStrategy = .useDefaultKeys

        print("1) Response with XML - no namespaces")
        print("Decoder keyDecodingStrategy: \(decoder.keyDecodingStrategy)")
        print()

        let ojp = try decoder.decode(OJPv2.self, from: xmlData)
        if let response = ojp.response {
            for placeResult in response.serviceDelivery.locationInformationDelivery.placeResults {
                print(placeResult)
                print()
            }
        }

        print("parse OK")
        guard let lir = ojp.response?.serviceDelivery.locationInformationDelivery else {
            throw NSError(domain: "Unexpected Empty", code: 1)
        }
        return lir
    }

    static func parseXMLKeepingNamespace(_ xmlData: Data) throws -> OJPv2Namespaced {
        // without namespaces
        let decoder2 = XMLDecoder()
        decoder2.keyDecodingStrategy = .convertFromCapitalized
        decoder2.keyDecodingStrategy = .useDefaultKeys

        let response2 = try decoder2.decode(OJPv2Namespaced.self, from: xmlData)
        print("2) Response with XML namespaces")
        print(response2)
        print()
        return response2
    }
}
