//
//  OJPv2+Extensions.swift
//
//
//  Created by Vasile Cotovanu on 20.03.2024.
//

import CoreLocation
import Foundation

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
