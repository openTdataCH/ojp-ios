//
//  Test.swift
//  OJP
//
//  Created by Lehnherr Reto on 20.06.2025.
//

@testable import OJP
import Testing
import XMLCoder

struct PersistanceTest {
    @Test func testPersistingTripResponseForChangeInPersonalService() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tr-continuous-leg-walk")
        let delivery = try await #require(OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery)

        guard case let .trip(tripDelivery) = delivery else {
            Issue.record("not a tripdelivery")
            return
        }

        let firstTrip = try #require(tripDelivery.tripResults.first?.trip)

        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let encoded = try encoder.encode(firstTrip)
        let decoded = try decoder.decode(OJPv2.Trip.self, from: encoded)

        #expect(decoded.tripHash == firstTrip.tripHash)
        guard case let .continous(continouousLeg) = decoded.legs.first?.legType else {
            Issue.record("expected a continuous leg")
            return
        }

        guard case let .personalService(personalService) = continouousLeg.service.type else {
            Issue.record("expected a personal service")
            return
        }

        #expect(personalService.personalMode == "foot")
    }
}
