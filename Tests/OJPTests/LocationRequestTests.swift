@testable import OJP
import XCTest

final class LocationRequestTests: XCTestCase {
    let locationInformationRequest = OJPHelpers.LocationInformationRequest(.init(language: "de", requesterReference: ""))

    func testGeoRestrictionHelpers() throws {
        // BBOX with Kleine Schanze as center + width / height of 1km
        let ojp = locationInformationRequest.requestWithBox(centerLongitude: 7.44029, centerLatitude: 46.94578, boxWidth: 1000.0)
        guard case let .initialInput(input) = ojp.request?.serviceRequest.locationInformationRequest!.input else { return XCTFail("invalid input type")
        }
        if let rectangle = input.geoRestriction?.rectangle {
            XCTAssertTrue(rectangle.lowerRight.longitude > rectangle.upperLeft.longitude)
            XCTAssertTrue(rectangle.upperLeft.latitude > rectangle.lowerRight.latitude)

            XCTAssertTrue(rectangle.upperLeft.longitude == 7.433703, "Unexpected upperLeft.longitude \(rectangle.upperLeft.longitude)")
            XCTAssertTrue(rectangle.upperLeft.latitude == 46.950277, "Unexpected upperLeft.latitude \(rectangle.upperLeft.latitude)")
            XCTAssertTrue(rectangle.lowerRight.longitude == 7.446877, "Unexpected lowerRight.longitude \(rectangle.lowerRight.longitude)")
            XCTAssertTrue(rectangle.lowerRight.latitude == 46.941283, "Unexpected lowerRight.latitude \(rectangle.lowerRight.latitude)")
        } else {
            XCTFail("Cant compute geoRestriction rectangle")
        }
    }

    func testStationsSortingByDistance() async throws {
        let mockLoader: Loader = { _ in
            let data = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-sorting")
            let response = HTTPURLResponse(url: URL(string: "https://localhost")!, statusCode: 200, httpVersion: "1.0", headerFields: [:])
            return (data, response!)
        }

        let ojpSdk = OJP(loadingStrategy: .mock(mockLoader))
        let nearbyStations = try await ojpSdk.requestPlaceResults(from: (long: 7.452178, lat: 46.948474))

        let nearbyPlaceResult = nearbyStations.first!.object

        let nearbyStopName = nearbyPlaceResult.place.name.text
        let expectedStopName = "Bern (Bern)"
        XCTAssert(nearbyStopName == expectedStopName, "Expected '\(expectedStopName)' got '\(nearbyStopName)' instead")

        let distance = nearbyStations.first!.distance
        let expectedDistance = 991.2
        XCTAssert(distance == expectedDistance, "Expected '\(expectedDistance)' got '\(distance)' instead")
    }

    func testBuildRequestBBOX() throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = locationInformationRequest.requestWith(bbox: bbox)

        let xmlString = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest)
        XCTAssert(!xmlString.isEmpty)
    }

    func testBuildRequestName() throws {
        let ojpRequest = locationInformationRequest.requestWithSearchTerm("Be", restrictions: .init(type: [.stop]))
        let xmlString = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest)
        XCTAssert(!xmlString.isEmpty)
    }

    @DecoderActor func testParseMinimumRequiredLIRResponse() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-minimum-response")
        guard let _ = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        XCTAssertTrue(true)
    }

    @DecoderActor func testParseRailBusAndUndergroundPtModes() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-lausanne")

        guard let locationInformationDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch locationInformationDelivery {
        case let .locationInformation(lir):
            XCTAssert(lir.placeResults.first?.place.modes.first?.ptMode == .rail)
            XCTAssert(lir.placeResults[1].place.modes.first?.ptMode == .bus)
            XCTAssert(lir.placeResults[2].place.modes.first?.ptMode == .underground)
        default:
            XCTFail()
        }
    }

    func testParseStopPlaceWithSloid() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-emmenmatt-sloid")
        let locationInformation = try await OJPDecoder.parseXML(xmlData)

        guard let locationInformationDelivery = locationInformation.response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        switch locationInformationDelivery {
        case let .locationInformation(lir):
            switch lir.placeResults.first!.place.place {
            case let .stopPlace(stopPlace):
                XCTAssert(stopPlace.stopPlaceRef == "ch:1:sloid:8206")
            case .address, .stopPoint, .topographicPlace:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testAddress() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-address")

        let locationInformation = try await OJPDecoder.parseXML(xmlData)
        guard let delivery = locationInformation.response?.serviceDelivery.delivery else {
            XCTFail("unexpected empty delivery")
            return
        }

        switch delivery {
        case let .locationInformation(locationInformation):
            for location in locationInformation.placeResults {
                switch location.place.place {
                case .stopPlace, .stopPoint, .topographicPlace:
                    XCTFail()
                case let .address(address):
                    XCTAssert(address.houseNumber == "48")
                    XCTAssert(address.topographicPlaceName == "Le Mouret")
                    XCTAssert(address.street == "Route des Russilles")
                }
            }
        default:
            XCTFail()
        }
    }
}
