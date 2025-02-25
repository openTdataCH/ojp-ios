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
    func testFetchStopEventRequest() async throws {
        let location = OJPv2.PlaceContext(
            placeRef: .stopPointRef(
                .init(
                    stopPointRef: "8507000",
                    name: .init("Bern")
                )
            ),
            depArrTime: nil
        )

        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let stopEvents = try await ojpSdk.requestStopEvent(
            location: location,
            params: nil
        )

        XCTAssert(!stopEvents.stopEventResults.isEmpty)
    }

    func testFetchStations() async throws {
        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let stations = try await ojpSdk.requestPlaceResults(from: "Bern", restrictions: .init(type: [.stop]))

        XCTAssert(!stations.isEmpty)
    }

    func testFetchNearbyStations() async throws {
        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let nearbyStations = try await ojpSdk.requestPlaceResults(from: (long: 7.452178, lat: 46.948474))

        XCTAssert(!nearbyStations.isEmpty)
    }

    func testFetchStationByDidok() async throws {
        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let nearbyStations = try await ojpSdk.requestPlaceResults(placeRef: .stopPointRef(.init(stopPointRef: "8507000", name: .init("Bern"))), restrictions: .init(type: [.stop]))

        XCTAssert(!nearbyStations.isEmpty)
    }

    func testFetchTripWithDidoks() async throws {
        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let originDidok = OJPv2.PlaceRefChoice.stopPlaceRef(.init(stopPlaceRef: "8507110", name: .init("8507110")))
        let destinationDidok = OJPv2.PlaceRefChoice.stopPlaceRef(.init(stopPlaceRef: "8508052", name: .init("8508052")))

        let tripDelivery = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(includeIntermediateStops: true, includeAllRestrictedLines: true))

        XCTAssert(!tripDelivery.tripResults.isEmpty)
    }

    func testFetchTripWithDifferentNumberOfResultPolicies() async throws {
        let ojpSdk = await OJP(loadingStrategy: .http(.int))

        let originDidok = OJPv2.PlaceRefChoice.stopPlaceRef(.init(stopPlaceRef: "8507110", name: .init("8507110")))
        let destinationDidok = OJPv2.PlaceRefChoice.stopPlaceRef(.init(stopPlaceRef: "8508052", name: .init("8508052")))

        let tripsNow = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(includeIntermediateStops: true, includeAllRestrictedLines: true)).tripResults

        let tripsBefore = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(numberOfResults: .numbers(before: 20, after: 0), includeIntermediateStops: true)).tripResults

        let tripsAfter = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(numberOfResults: .numbers(before: 0, after: 20), includeIntermediateStops: true)).tripResults

        let beforeDates = tripsBefore.compactMap(\.trip).map(\.startTime)
        let afterDates = tripsAfter.compactMap(\.trip).map(\.startTime)

        XCTAssertFalse(tripsBefore.isEmpty)
        XCTAssertFalse(tripsNow.isEmpty)
        XCTAssertFalse(tripsAfter.isEmpty)

        XCTAssertLessThan(beforeDates.last!, afterDates.first!)

        XCTAssertEqual(beforeDates.sorted(), beforeDates)
        XCTAssertEqual(afterDates.sorted(), afterDates)
    }
}
