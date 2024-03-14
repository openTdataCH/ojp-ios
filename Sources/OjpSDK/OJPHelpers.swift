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

    static func buildXMLRequest() throws -> String {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojp = OJPHelpers.LocationInformationRequest.initWithBBOX(bbox: bbox)

        let ojpXMLData = try XMLEncoder().encode(ojp, withRootKey: "ojp")
        guard let ojpXML = String(data: ojpXMLData, encoding: .utf8) else {
            throw NSError(domain: "can't encode String", code: 1)
        }

        print(ojpXML)
        return ojpXML
    }

    static func parseXMLStrippingNamespace(_ xmlData: Data) throws -> OJP.LocationInformationDelivery {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        decoder.dateDecodingStrategy = .iso8601
        decoder.shouldProcessNamespaces = true
        decoder.keyDecodingStrategy = .useDefaultKeys

        print("1) Response with XML - no namespaces")
        print("Decoder keyDecodingStrategy: \(decoder.keyDecodingStrategy)")
        print()

        let ojp = try decoder.decode(OJP.self, from: xmlData)
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

    static func parseXMLKeepingNamespace(_ xmlData: Data) throws -> OJPNamespaced {
        // without namespaces
        let decoder2 = XMLDecoder()
        decoder2.keyDecodingStrategy = .convertFromCapitalized
        decoder2.keyDecodingStrategy = .useDefaultKeys

        let response2 = try decoder2.decode(OJPNamespaced.self, from: xmlData)
        print("2) Response with XML namespaces")
        print(response2)
        print()
        return response2
    }
}
