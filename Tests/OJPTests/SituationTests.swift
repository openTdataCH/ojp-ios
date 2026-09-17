//
//  SituationTests.swift
//  OJP
//
//  Created by Lehnherr Reto on 17.09.2026.
//

import Testing
@testable import OJP


struct SituationTests {

    @Test func testSituationMultipleContentElements() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "ser-situation-multipleContentElements")
        let ser = try await OJPDecoder.parseXML(xmlData)

        guard case let .stopEvent(delivery) = ser.response?.serviceDelivery.delivery else {
            return #expect(Bool(false))
        }
        let ptSituations = try #require(delivery.stopEventResponseContext?.situations?.ptSituations)
        #expect(ptSituations.count == 1)
        let action = try #require(ptSituations.first?.publishingActions?.first)
        #expect(action.passengerInformationActions.count == 1)
        let passengerInformationAction = try #require(action.passengerInformationActions.first)
        let textualContent = try #require(passengerInformationAction.textualContents.first)
        #expect(textualContent.consequenceContents.count == 2)
        #expect(textualContent.recommendationContents.count == 2)
        #expect(textualContent.remarkContents.count == 2)
    }
    
    @Test func testSituationEmptyRecommendationElment() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tir-situation-empty")
        let ser = try await OJPDecoder.parseXML(xmlData)

        guard case let .tripInfo(delivery) = ser.response?.serviceDelivery.delivery else {
            return #expect(Bool(false))
        }
        let ptSituations = try #require(delivery.tripInfoResponseContext?.situations?.ptSituations)
        #expect(ptSituations.count == 1)
        let action = try #require(ptSituations.first?.publishingActions?.first)
        #expect(action.passengerInformationActions.count == 1)
        let passengerInformationAction = try #require(action.passengerInformationActions.first)
        let textualContent = try #require(passengerInformationAction.textualContents.first)
        #expect(textualContent.consequenceContents.count == 1)
        #expect(textualContent.recommendationContents.isEmpty)
        #expect(textualContent.remarkContents.isEmpty)
    }

}
