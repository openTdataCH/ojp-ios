//
//  PointOfInterestTests.swift
//  OJP
//
//  Created by Lehnherr Reto on 29.06.2026.
//

@testable import OJP
import Testing
import Foundation

struct PointOfInterestTests {

    @Test func testSharedMoblity() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-shared-mobility")

        guard case let .locationInformation(delivery) = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return #expect(Bool(false))
        }
        let placeResults = delivery.placeResults
        #expect(placeResults.count == 17)

        let firstResult = try #require(placeResults.first)
        #expect(firstResult.place.name.text == "Voi")
        if case let .pointOfInterest(voiPoi) = firstResult.place.place {
            let url = try #require(voiPoi.poiAdditionalInformation?["rental_uris.ios"])
            #expect(URL(string: url) != nil)
            let poiClassification = try #require(voiPoi.pointOfInterestCategory?.first)
            #expect(poiClassification == .pointOfInterestClassification("escooter_rental"))

            let sharingCategory = try #require(voiPoi.sharingCategories.first)
            #expect(sharingCategory == .escooter)
        }

        let mobilityResult = placeResults[5]
        #expect(mobilityResult.place.name.text == "Mobility")
        #expect(mobilityResult.geoPosition.longitude == 7.44681)
        #expect(mobilityResult.geoPosition.latitude == 46.9495)
        if case let .pointOfInterest(mobilityPoi) = mobilityResult.place.place {
            let poiClassification = try #require(mobilityPoi.pointOfInterestCategory?.first)
            #expect(poiClassification == .pointOfInterestClassification("car_sharing"))

            let sharingCategory = try #require(mobilityPoi.sharingCategories.first)
            #expect(sharingCategory == .car)
            #expect(mobilityPoi.poiAdditionalInformation?["num_vehicles_available"] == "1")
        }


        let velospotResult = try #require(placeResults.last)
        #expect(velospotResult.place.name.text == "Velospot")
        #expect(velospotResult.geoPosition.longitude == 7.44053)
        #expect(velospotResult.geoPosition.latitude == 46.94835)
        if case let .pointOfInterest(velospotPoi) = velospotResult.place.place {
            let poiClassification = try #require(velospotPoi.pointOfInterestCategory?.first)
            #expect(poiClassification == .pointOfInterestClassification("bicycle_rental"))

            let sharingCategory = try #require(velospotPoi.sharingCategories.first)
            #expect(sharingCategory == .bike)
            #expect(velospotPoi.poiAdditionalInformation?["num_vehicles_available"] == "15")
        }
    }
}
