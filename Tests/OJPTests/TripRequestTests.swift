@testable import OJP
import XCTest

final class TripRequestTests: XCTestCase {
    func testParseMinimalTripResponse() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-gurten-trip1-minimal-response")
        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
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
                XCTAssertEqual(trip.duration.iso8601, "PT8H55M")
                XCTAssertEqual(trip.legs.count, 1)

                guard let leg = trip.legs.first else {
                    return XCTFail("Missing trip")
                }

                XCTAssertEqual(leg.id, 1)
                XCTAssertEqual(leg.duration?.iso8601, "PT15M")

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

    func testParseTrip_BE_ZH() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "trip-bern-zh-response")

        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch tripDelivery {
        case let .trip(trip):
            XCTAssertEqual(trip.tripResults.count, 10)
        default:
            XCTFail()
        }
    }

    func testParseTrip_With_Tranfer_Legs() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-with-transfer-legs")

        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch tripDelivery {
        case let .trip(trip):
            XCTAssertEqual(trip.tripResults.count, 10)
        default:
            XCTFail()
        }
    }

    func testParseTrip_With_ContinousWalkLeg() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-continuous-leg-walk")

        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch tripDelivery {
        case let .trip(trip):
            XCTAssertEqual(trip.tripResults.count, 6)
        default:
            XCTFail()
        }
    }

    func testTripHash() async throws {
        let xmlData1 = try TestHelpers.loadXML(xmlFilename: "tr-bern-baerenplatz1")
        let xmlData2 = try TestHelpers.loadXML(xmlFilename: "tr-bern-baerenplatz2")

        guard case let .trip(tripDelivery1) = try await OJPDecoder.parseXML(xmlData1).response?.serviceDelivery.delivery,
              case let .trip(tripDelivery2) = try await OJPDecoder.parseXML(xmlData2).response?.serviceDelivery.delivery
        else {
            return XCTFail("unexpected empty")
        }
        XCTAssertEqual(tripDelivery1.tripResults.count, tripDelivery2.tripResults.count)
        let trips1 = tripDelivery1.tripResults.compactMap(\.trip)
        let trips2 = tripDelivery2.tripResults.compactMap(\.trip)

        XCTAssertNotEqual(trips1.map(\.tripHash), trips2.map(\.tripHash))

        let sum = trips1 + trips2
        XCTAssertEqual(sum.count, 12)

        var insertedHashes: Set<Int> = []
        var uniqued: [OJPv2.Trip] = []

        for item in sum {
            guard !insertedHashes.contains(item.tripHash) else {
                continue
            }
            uniqued.append(item)
            insertedHashes.insert(item.tripHash)
        }

        XCTAssertEqual(uniqued.count, 11)
    }

    // MARK: - Situations (maybe move to separate file)

    func testSituationParsing() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-fribourg-berne")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }
            guard let responseContext = tripDelivery.tripResponseContext else {
                return XCTFail("expected to have a tripResponseContext")
            }
            dump(responseContext)
        } catch {
            print(error)
            throw error
        }
    }

    func testSituationsMappingOnLegs() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-fribourg-basel")

        guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        guard let responseContext = tripDelivery.tripResponseContext else {
            return XCTFail("expected to have a tripResponseContext")
        }
        let ptSituations = tripDelivery.ptSituations
        XCTAssertEqual(ptSituations.count, 2)
        XCTAssertEqual(ptSituations.map(\.situationNumber), responseContext.situations.ptSituations?.map(\.situationNumber))

        if let firstTrip = tripDelivery.tripResults.first?.trip {
            if case let .timed(firstLeg) = firstTrip.legs.first?.legType {
                let situations = firstLeg.relevantPtSituations(allPtSituations: ptSituations)
                XCTAssertEqual(situations.count, 1)
                XCTAssertEqual(situations.first?.situationNumber, "ch:1:sstid:100001:dccd662a-e519-468b-b06b-1fdb25727282-1")
            } else {
                XCTFail()
            }

            if case let .timed(lastLeg) = firstTrip.legs.last?.legType {
                let situations = lastLeg.relevantPtSituations(allPtSituations: ptSituations)
                XCTAssertEqual(situations.count, 2)
                XCTAssertEqual(situations.map(\.situationNumber), [
                    "ch:1:sstid:100001:dccd662a-e519-468b-b06b-1fdb25727282-1",
                    "ch:1:sstid:100001:dfc1dfd3-bbe0-441c-89df-7a309eb7b358-1",
                ])
            } else {
                XCTFail()
            }
        }
    }

    func testSituationsMappingUniqueness() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-fribourg-basel")

        guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        guard let responseContext = tripDelivery.tripResponseContext else {
            return XCTFail("expected to have a tripResponseContext")
        }
        let ptSituations = tripDelivery.ptSituations
        XCTAssertEqual(ptSituations.count, 2)
        XCTAssertEqual(ptSituations.map(\.situationNumber), responseContext.situations.ptSituations?.map(\.situationNumber))
        let situations = try XCTUnwrap(responseContext.situations.ptSituations)
        let duplicateSituations = situations + situations
        XCTAssertEqual(duplicateSituations.count, 4)
        
        if let firstTrip = tripDelivery.tripResults.first?.trip {
            if case let .timed(firstLeg) = firstTrip.legs.first?.legType {
                let situations = firstLeg.relevantPtSituations(allPtSituations: duplicateSituations)
                XCTAssertEqual(situations.count, 1)
                XCTAssertEqual(situations.first?.situationNumber, "ch:1:sstid:100001:dccd662a-e519-468b-b06b-1fdb25727282-1")
            } else {
                XCTFail()
            }
        }
    }

    func testSituationsMappingOnTrip() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-fribourg-basel")

        guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        guard let responseContext = tripDelivery.tripResponseContext else {
            return XCTFail("expected to have a tripResponseContext")
        }
        let ptSituations = tripDelivery.ptSituations
        XCTAssertEqual(ptSituations.count, 2)
        XCTAssertEqual(ptSituations.map(\.situationNumber), responseContext.situations.ptSituations?.map(\.situationNumber))

        let firstTrip = try XCTUnwrap(tripDelivery.tripResults.first?.trip)

        XCTAssertTrue(firstTrip.hasSituation(allPtSituations: ptSituations))

        let situationsOfFirstTrip = firstTrip.relevantPtSituations(allPtSituations: ptSituations)
        XCTAssertEqual(situationsOfFirstTrip.count, 2)
        XCTAssertEqual(situationsOfFirstTrip.map(\.situationNumber), [
            "ch:1:sstid:100001:dccd662a-e519-468b-b06b-1fdb25727282-1",
            "ch:1:sstid:100001:dfc1dfd3-bbe0-441c-89df-7a309eb7b358-1",
        ])
    }

    // MARK: - TripStatus

    func testTripStatusInfeasible() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-infeasible")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }

            let infeasibleTrip = tripDelivery.tripResults.first
            XCTAssertEqual(infeasibleTrip?.trip?.tripStatus.infeasible, true)
        }
    }

    func testTripStatusCancelled() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-cancellation")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }

            let cancelledTrip = try XCTUnwrap(tripDelivery.tripResults[1].trip)
            XCTAssertEqual(cancelledTrip.tripStatus.cancelled, true)
        }
    }

    func testTripStatusDeviation() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-deviation-notActuallyALiveExample")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }

            let cancelledTrip = try XCTUnwrap(tripDelivery.tripResults[1].trip)
            XCTAssertEqual(cancelledTrip.tripStatus.deviation, true)
        }
    }

    func testTripNotServicedStop() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "trip-not-serviced")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }

            let firstTrip = try XCTUnwrap(tripDelivery.tripResults.first?.trip)
            if case let .timed(legWithNotServicedStop) = firstTrip.legs[1].legType {
                for leg in legWithNotServicedStop.legsIntermediate {
                    XCTAssertEqual(leg.stopCallStatus.notServicedStop, leg.stopPointName.text == "Neuchâtel, Gouttes d'or")
                }
            } else {
                XCTFail()
            }
        }
    }

    func testEmptyTripResultEdgeCase() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "trip-edgecase-empty-tripresult")
        do {
            guard case let .trip(tripDelivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
                return XCTFail("unexpected empty")
            }
            XCTAssertTrue(tripDelivery.tripResults.isEmpty)
        }
    }
}
