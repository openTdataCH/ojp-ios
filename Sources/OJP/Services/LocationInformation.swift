//
//  LocationInformation.swift
//
//
//  Created by Lehnherr Reto on 15.03.2024.
//

import Foundation

class LocationInformation {
    let ojp: OJP

    init(ojp: OJP) {
        self.ojp = ojp
    }

    func nearbyPlaces(latitude _: Double, longitude _: Double, limit _: Int = 25, min _: Int = 5) throws -> [OJPv2.Place] {
        // create initial bounding box and request

        // perform initial Request and redo with bigger bounding box if count < min

        // sort and return

        throw OJPError.notImplemented
    }
}
