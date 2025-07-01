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
        let secondClass = first(where: { $0.fareClass == .secondClass })
        return .init(
            expectedFirstClassOccupancy: firstClass?.occupancyLevel,
            expectedSecondClassOccupancy: secondClass?.occupancyLevel
        )
    }
}

/// Convenience type to work with expected occupancies.
///
/// Use `expectedOccuppancy` on ``OJP/Swift/Array``
public struct ExpectedOccupancy: Codable, Sendable {
    public let expectedFirstClassOccupancy: OJPv2.OccupancyLevel?
    public let expectedSecondClassOccupancy: OJPv2.OccupancyLevel?

    public init(expectedFirstClassOccupancy: OJPv2.OccupancyLevel? = nil, expectedSecondClassOccupancy: OJPv2.OccupancyLevel? = nil) {
        self.expectedFirstClassOccupancy = expectedFirstClassOccupancy
        self.expectedSecondClassOccupancy = expectedSecondClassOccupancy
    }

    public var hasOccupancy: Bool {
        expectedFirstClassOccupancy != nil || expectedSecondClassOccupancy != nil
    }
}

extension OJPv2.OccupancyLevel: Comparable {
    public static func < (lhs: OJPv2.OccupancyLevel, rhs: OJPv2.OccupancyLevel) -> Bool {
        lhs.weight < rhs.weight
    }

    private var weight: Int {
        switch self {
        case .unknown, .empty, .undefined:
            0
        case .manySeatsAvailable:
            1
        case .fewSeatsAvailable:
            2
        case .crushedStandingRoomOnly, .standingRoomOnly, .full, .notAcceptingPassengers:
            3
        }
    }

}
