//
//  Geo.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 14.03.2024.
//

import Foundation

struct Geo {
    struct Bbox {
        let minX: Double
        let minY: Double
        let maxX: Double
        let maxY: Double

        init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
            self.minX = minX
            self.minY = minY
            self.maxX = maxX
            self.maxY = maxY
        }

        init(minLongitude: Double, minLatitude: Double, maxLongitude: Double, maxLatitude: Double) {
            self.init(minX: minLongitude, minY: minLatitude, maxX: maxLongitude, maxY: maxLatitude)
        }
    }
}
