//
//  OJPv2+Extensions.swift
//
//
//  Created by Vasile Cotovanu on 20.03.2024.
//

import CoreLocation
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
    public var geoPosition: OJPv2.GeoPosition {
        place.geoPosition
    }
}

public extension OJPv2.GeoPosition {
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
