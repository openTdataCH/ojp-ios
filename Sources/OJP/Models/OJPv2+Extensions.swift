//
//  OJPv2+Extensions.swift
//
//
//  Created by Vasile Cotovanu on 20.03.2024.
//

import Foundation

extension OJPv2.PlaceResult: GeoAware {
    public var coords: (longitude: Double, latitude: Double) {
        return (self.place.geoPosition.longitude, self.place.geoPosition.latitude)
    }
}
