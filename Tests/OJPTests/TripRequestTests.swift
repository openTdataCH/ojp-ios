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
            case let .trip(trip):
                let dateFormatter = ISO8601DateFormatter()
                XCTAssertEqual(dateFormatter.string(from: trip.startTime), "2024-05-14T21:45:00Z")
                XCTAssertEqual(dateFormatter.string(from: trip.endTime), "2024-05-15T06:40:00Z")
                XCTAssertEqual(trip.transfers, 4)
                XCTAssertEqual(trip.duration, "PT8H55M")
                XCTAssertEqual(trip.legs.count, 1)

                guard let leg = trip.legs.first else {
                    return XCTFail("Missing trip")
                }

                XCTAssertEqual(leg.id, 1)
                XCTAssertEqual(leg.duration, "PT15M")

                guard case let .timed(timedLeg) = leg.legType else {
                    return XCTFail("Expected a timed Leg")
                }

                let legBoard = timedLeg.legBoard
                XCTAssertEqual(legBoard.stopPointRef, "8507099")
                XCTAssertEqual(legBoard.stopPointName.text, "Gurten Kulm")
                XCTAssertEqual(dateFormatter.string(from: legBoard.serviceDeparture.timetabledTime), "2024-05-14T21:45:00Z")

                XCTAssert(timedLeg.legsIntermediate.count == 0)
                XCTAssert(timedLeg.legTrack == nil)
                let legAlight = timedLeg.legAlight
                XCTAssertEqual(legAlight.stopPointRef, "8507097")
                XCTAssertEqual(legAlight.stopPointName.text, "Wabern (Gurtenbahn)")
                XCTAssertEqual(dateFormatter.string(from: legAlight.serviceArrival.timetabledTime), "2024-05-14T22:00:00Z")

                XCTAssertEqual(timedLeg.service.mode.ptMode, .bus)

                let attributeCodes = timedLeg.service.attributes.map(\.code)
                let attributeTexts = timedLeg.service.attributes.map(\.userText.text)
                XCTAssertEqual(attributeCodes, ["A__VN", "A__NF"])
                XCTAssertEqual(attributeTexts, ["VELOS: Keine Beförderung möglich", "Niederflureinstieg"])
            case .tripSummary:
                XCTFail("TripSummary is not expected")
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
    
    func testParseTrip_With_Tranfer_Legs() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-with-transfer-legs")

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
