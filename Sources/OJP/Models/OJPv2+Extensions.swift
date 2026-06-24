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

public extension OJPv2 {
    /// A high level category of a ``OJPv2/PlaceResult`` that can be shown on a map.
    enum MapPlaceCategory: Hashable, Sendable {
        case station
        case sharedCar
        case sharedBicycle
        case sharedScooter
    }
}

public extension OJPv2.PlaceResult {
    /// Classifies a place result into a high level ``OJPv2/MapPlaceCategory``.
    ///
    /// Stops and stop places are stations. PointOfInterest results coming from a shared mobility request
    /// are classified using their OJP classification (`car_sharing`, `bicycle_rental`, `escooter_rental`).
    /// Returns `nil` for results that don't fit any of these categories.
    var mapCategory: OJPv2.MapPlaceCategory? {
        switch place.place {
        case .stopPlace, .stopPoint:
            return .station
        case let .pointOfInterest(poi):
            let classifications = poi.classifications
            if classifications.contains("car_sharing") {
                return .sharedCar
            }
            if classifications.contains("bicycle_rental") {
                return .sharedBicycle
            }
            if classifications.contains("escooter_rental") {
                return .sharedScooter
            }
            return nil
        case .address, .topographicPlace:
            return nil
        }
    }

    /// The underlying ``OJPv2/PointOfInterest`` if this place result is a point of interest.
    var pointOfInterest: OJPv2.PointOfInterest? {
        if case let .pointOfInterest(poi) = place.place {
            return poi
        }
        return nil
    }
}
