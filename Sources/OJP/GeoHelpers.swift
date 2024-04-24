//
//  GeoHelpers.swift
//
//
//  Created by Vasile Cotovanu on 17.03.2024.
//

import Foundation

extension Double {
    var degreesToRadians: Double {
        self * .pi / 180
    }
}

enum GeoHelpers {
    public static func calculateDistance(lon1: Double, lat1: Double, lon2: Double, lat2: Double) -> Double {
        let earthRadius = 6371.0

        let latDistance = (lat2 - lat1).degreesToRadians
        let lonDistance = (lon2 - lon1).degreesToRadians
        let a = sin(latDistance / 2) * sin(latDistance / 2) +
            cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) *
            sin(lonDistance / 2) * sin(lonDistance / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distanceMeters = earthRadius * c * 1000

        return distanceMeters.rounded(to: 1)
    }

    public static func sort<T: GeoAware>(geoAwareObjects: [T], from point: Point) -> [NearbyObject<T>] {
        var nearbyObjects = geoAwareObjects.map { geoAwareObject in
            if let coords = geoAwareObject.coords {
                let distance = GeoHelpers.calculateDistance(lon1: point.long, lat1: point.lat, lon2: coords.long, lat2: coords.lat)
                return NearbyObject(object: geoAwareObject, distance: distance)
            } else {
                return NearbyObject(object: geoAwareObject, distance: 0)
            }
        }

        nearbyObjects.sort { $0.distance < $1.distance }

        return nearbyObjects
    }
}
