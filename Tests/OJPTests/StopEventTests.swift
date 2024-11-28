//
//  StopEventTests.swift
//  OJP
//
//  Created by Lehnherr Reto on 28.11.2024.
//

@testable import OJP
import Testing

struct StopEventTests {
    @Test func testGroupedStopEvents() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "ser-from-address")
        let ser = try await OJPDecoder.parseXML(xmlData)

        guard case let .stopEvent(delivery) = ser.response?.serviceDelivery.delivery else {
            return #expect(Bool(false))
        }
        let grouped = delivery.stopEventsGroupedByStation
        #expect(grouped.keys.count == 12)
        #expect(!delivery.isSameStop)
    }

    @Test func testSameStop() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "ser-bern")
        let ser = try await OJPDecoder.parseXML(xmlData)

        guard case let .stopEvent(delivery) = ser.response?.serviceDelivery.delivery else {
            return #expect(Bool(false))
        }
        #expect(delivery.isSameStop)
    }
}
