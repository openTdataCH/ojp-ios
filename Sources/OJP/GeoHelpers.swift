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

        return distanceMeters
    }
}

struct NearbyObject<T> {
    var object: T
    var distance: Double
}
