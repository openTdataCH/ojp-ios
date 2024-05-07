//
//  SystemTests.swift
//
//
//  Created by Terence Alberti on 01.05.2024.
//

@testable import OJP
import XCTest

// the goal is to check if also the requests done on the backend are correctly parsed by the sdk,
// in order to ensure that backend changes will not break the SDK.
//
// I know that this is an anti-pattern but it's an easy solution in order to have quick results
// without making a big effort.
final class SystemTests: XCTestCase {
    func testFetchStations() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let stations = try await ojpSdk.requestLocations(from: "Bern", restrictions: .init(type: [.stop]))

        XCTAssert(!stations.isEmpty)
    }

    func testFetchNearbyStations() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let nearbyStations = try await ojpSdk.requestLocations(from: (long: 7.452178, lat: 46.948474))

        XCTAssert(!nearbyStations.isEmpty)
    }
}
