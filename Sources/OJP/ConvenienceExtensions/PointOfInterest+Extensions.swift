//
//  PointOfInterest+Extensions.swift
//  OJP
//
//  Created by Lehnherr Reto on 25.06.2026.
//
import SwiftUI

public enum SharingCategory: String {
    case escooter = "escooter_rental"
    case bike = "bicycle_rental"
    case car = "car_sharing"
    case chargingStation = "charging_station"

    public var image: Image {
        switch self {
        case .escooter:
            Image(systemName: "scooter")
        case .bike:
            Image(systemName: "bicycle")
        case .car:
            Image(systemName: "car")
        case .chargingStation:
            Image(systemName: "ev.charger")
        }
    }
}

extension OJPv2.PointOfInterest {
    public var sharingCategories: [SharingCategory] {
        pointOfInterestCategory?.compactMap { SharingCategory(rawValue: $0.value) } ?? []
    }
}
