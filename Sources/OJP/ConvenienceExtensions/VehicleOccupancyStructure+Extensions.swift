//
//  VehicleOccupancyStructure+Extensions.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.06.2025.
//
import Foundation

public extension [OJPv2.VehicleOccupancyStructure] {
    /// Property to create a convenience type to display the exected occupancy
    var expectedOccupancy: ExpectedOccupancy {
        let firstClass = first(where: { $0.fareClass == .firstClass })
        let secondClass = first(where: { $0.fareClass == .firstClass })
        return .init(
            expectedFirstClassOccupancy: firstClass?.occupancyLevel,
            expectedSecondClassOccupancy: secondClass?.occupancyLevel
        )
    }
}

/// Convenience type to work with expected occupancies.
///
/// Use `expectedOccuppancy` on ``OJP/Swift/Array``
public struct ExpectedOccupancy: Sendable {
    public let expectedFirstClassOccupancy: OJPv2.OccupancyLevel?
    public let expectedSecondClassOccupancy: OJPv2.OccupancyLevel?

    public var hasOccupancy: Bool {
        expectedFirstClassOccupancy != nil || expectedSecondClassOccupancy != nil
    }
}
