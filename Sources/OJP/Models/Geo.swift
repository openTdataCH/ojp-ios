//
//  Geo.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation

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
    var object: T
    var distance: Double
}

public protocol GeoAware {
    var coords: (longitude: Double, latitude: Double) { get }
}

