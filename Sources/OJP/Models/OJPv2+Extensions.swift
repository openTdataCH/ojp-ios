//
//  OJPv2+Extensions.swift
//
//
//  Created by Vasile Cotovanu on 20.03.2024.
//

import Foundation

public extension OJPv2.Mode {
    enum PtMode: String {
        case rail
        case bus
        case tram
        case water
        case telecabin
        case underground
        case undefined
    }

    var ptModeType: PtMode {
        if let ptMode = PtMode(rawValue: ptMode) {
            ptMode
        } else {
            .undefined
        }
    }
}

extension OJPv2.PlaceResult: GeoAware {
    public var coords: Point {
        (long: place.geoPosition.longitude, lat: place.geoPosition.latitude)
    }
}
