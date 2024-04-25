//
//  Geo.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation

public typealias Point = (long: Double, lat: Double)

public struct Geo {
    public struct Bbox {
        public let minX: Double
        public let minY: Double
        public let maxX: Double
        public let maxY: Double

        public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
            self.minX = minX
            self.minY = minY
            self.maxX = maxX
            self.maxY = maxY
        }

        public init(minLongitude: Double, minLatitude: Double, maxLongitude: Double, maxLatitude: Double) {
            self.init(minX: minLongitude, minY: minLatitude, maxX: maxLongitude, maxY: maxLatitude)
        }
    }
}

public struct NearbyObject<T> {
    public var object: T
    public internal(set) var coords: Point
    public var distance: Double

    init(geoAware: GeoAware<T>, point: Point) {
        object = geoAware.object
        coords = geoAware.coords
        distance = GeoHelpers.calculateDistance(lon1: point.long, lat1: point.lat, lon2: coords.long, lat2: coords.lat)
    }
}

public struct GeoAware<T> {
    var object: T
    var coords: Point
}
