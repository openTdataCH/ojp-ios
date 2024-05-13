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
    public var distance: Double
}

public protocol GeoAware {
    var geoPosition: OJPv2.GeoPosition { get }
}
