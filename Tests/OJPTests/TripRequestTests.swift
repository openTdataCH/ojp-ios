@testable import OJP
import XCTest

final class TripRequestTests: XCTestCase {
    func testParseMinimalTripResponse() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-gurten-rigi-trip1-minimal-response")
        guard let tripDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        if case let .trip(trips) = tripDelivery {
            XCTAssert(trips.tripResults.count == 1)

            let trip = trips.tripResults.first!

            XCTAssertEqual(trip.id, "ID-E63FDE7C-080D-4FA8-AEC7-EF1C5F31010E")
            switch trip.tripType {
            case .trip(let trip):
                let dateFormatter = ISO8601DateFormatter()
                XCTAssertEqual(dateFormatter.string(from: trip.startTime), "2024-05-14T21:45:00Z")
                XCTAssertEqual(dateFormatter.string(from: trip.endTime), "2024-05-15T06:40:00Z")
                XCTAssertEqual(trip.transfers, 4)
                XCTAssertEqual(trip.duration, "PT8H55M")
                XCTAssertEqual(trip.legs.count, 1)

            case .tripSummary:
                XCTFail("Trip Summary is not expected")
            }
            return
        }
        XCTFail()
    }

    func testParseTrip_ZH_BE() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "trip-zh-bern-response")

        guard let tripDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch tripDelivery {
        case let .trip(trip):
            debugPrint("\(trip.calcTime!)")
            XCTAssert(true)
        default:
            XCTFail()
        }
    }
}
