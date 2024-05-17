@testable import OJP
import XCTest

final class TripRequestTests: XCTestCase {
    func testParseMinimalTripResponse() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-gurten-rigi-trip1-minimal-response")
        guard let tripDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        if case let .trip(trip) = tripDelivery {
            XCTAssert(trip.tripResults.count == 1)
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
