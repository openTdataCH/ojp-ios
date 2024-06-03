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

        let stations = try await ojpSdk.requestPlaceResults(from: "Bern", restrictions: .init(type: [.stop]))

        XCTAssert(!stations.isEmpty)
    }

    func testFetchNearbyStations() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let nearbyStations = try await ojpSdk.requestPlaceResults(from: (long: 7.452178, lat: 46.948474))

        XCTAssert(!nearbyStations.isEmpty)
    }

    func testFetchTripWithDidoks() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let originDidok = OJPv2.PlaceRefChoice.stopPlaceRef("8507110")
        let destinationDidok = OJPv2.PlaceRefChoice.stopPlaceRef("8508052")

        let trips = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(includeIntermediateStops: true))

        XCTAssert(!trips.isEmpty)
    }

    func testFetchTripWithDifferentNumberOfResultPolicies() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let originDidok = OJPv2.PlaceRefChoice.stopPlaceRef("8507110")
        let destinationDidok = OJPv2.PlaceRefChoice.stopPlaceRef("8508052")

        let tripsNow = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(includeIntermediateStops: true))

        let tripsBefore = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(numberOfResult: .before(20), includeIntermediateStops: true))

        let tripsAfter = try await ojpSdk.requestTrips(from: originDidok, to: destinationDidok, params: .init(numberOfResult: .after(20), includeIntermediateStops: true))

        let nowDates = tripsNow.compactMap(\.tripType.trip).map { ($0.startTime, $0.endTime) }

        let beforeDates = tripsBefore.compactMap(\.tripType.trip).map { ($0.startTime, $0.endTime) }

        let afterDates = tripsAfter.compactMap(\.tripType.trip).map { ($0.startTime, $0.endTime) }

//        print("now")
//        print(nowDates.map({ "Start: \($0.0.formatted(.iso8601)) – End: \($0.1.formatted(.iso8601))" }))
//
        print("----")
        print("before")
        print(beforeDates.map { "Start: \($0.0.formatted(.iso8601)) – End: \($0.1.formatted(.iso8601))" })

        print("----")
        print("after")
        print(afterDates.map { "Start: \($0.0.formatted(.iso8601)) – End: \($0.1.formatted(.iso8601))" })

        //        XCTAssert(afterDates != beforeDates)

        //        XCTAssert(!trips.isEmpty)
    }
    //
//    func testFetchTripWithCoordinates() async throws {
//        let ojpSdk = OJP(loadingStrategy: .http(.int))
//
//        let originDidok = OJPv2.PlaceRefChoice.geoPosition(.init(longitude: 47.54741205505015, latitude: 7.589562790156526))
//        let destinationDidok = OJPv2.PlaceRefChoice.geoPosition(.init(longitude: 47.570306321253796, latitude: 7.572529383710242))
//
//        let trips = try await ojpSdk.requestTrips(from: originDidok, destinationPlaceRef: destinationDidok, params: .init(numberOfResultsBefore: nil, numberOfResultsAfter: 6, includeTrackSections: nil, includeLegProjection: nil, includeTurnDescription: nil, includeIntermediateStops: true))
//
//        XCTAssert(!trips.isEmpty)
//    }
}
