//
//  OJPv2+Extensions.swift
//
//
//  Created by Vasile Cotovanu on 20.03.2024.
//

import Foundation

extension OJPv2.PlaceResult: GeoAware {
    public var coords: Point {
        (long: place.geoPosition.longitude, lat: place.geoPosition.latitude)
    }
}
