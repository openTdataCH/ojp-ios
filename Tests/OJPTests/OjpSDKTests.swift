@testable import OJP
import XCTest

final class OjpSDKTests: XCTestCase {
    let locationInformationRequest = OJPHelpers.LocationInformationRequest(requesterReference: "")

    func testLoadFromBundle() throws {
        do {
            let data = try TestHelpers.loadXML()
            XCTAssert(!data.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testGeoRestrictionHelpers() throws {
        // BBOX with Kleine Schanze as center + width / height of 1km
        let ojp = locationInformationRequest.requestWithBox(centerLongitude: 7.44029, centerLatitude: 46.94578, boxWidth: 1000.0)

        if let rectangle = ojp.request?.serviceRequest.locationInformationRequest.initialInput.geoRestriction?.rectangle {
            XCTAssertTrue(rectangle.lowerRight.longitude > rectangle.upperLeft.longitude)
            XCTAssertTrue(rectangle.upperLeft.latitude > rectangle.lowerRight.latitude)

            XCTAssertTrue(rectangle.upperLeft.longitude == 7.433703, "Unexpected upperLeft.longitude \(rectangle.upperLeft.longitude)")
            XCTAssertTrue(rectangle.upperLeft.latitude == 46.950277, "Unexpected upperLeft.latitude \(rectangle.upperLeft.latitude)")
            XCTAssertTrue(rectangle.lowerRight.longitude == 7.446877, "Unexpected lowerRight.longitude \(rectangle.lowerRight.longitude)")
            XCTAssertTrue(rectangle.lowerRight.latitude == 46.941283, "Unexpected lowerRight.latitude \(rectangle.lowerRight.latitude)")
        } else {
            XCTFail("Cant compute geoRestriction rectangle")
            print(ojp)
        }
    }

    func testStationsSortingByDistance() async throws {
        let mockLoader: Loader = { _ in
            let data = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-sorting")
            let response = HTTPURLResponse(url: URL(string: "https://localhost")!, statusCode: 200, httpVersion: "1.0", headerFields: [:])
            return (data, response!)
        }

        let ojpSdk = OJP(loadingStrategy: .mock(mockLoader))
        let nearbyStations = try await ojpSdk.requestLocations(from: (long: 7.452178, lat: 46.948474))

        let nearbyPlaceResult = nearbyStations.first!.object

        let nearbyStopName = nearbyPlaceResult.place.name!.text
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

    func testParseXML() throws {
        let xmlData = try TestHelpers.loadXML()
        let locationInformation: OJPv2 = try OJPDecoder.parseXML(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }

    func testParseXMLWithSiriDefaultNamespace() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-ns")
        let locationInformation = try OJPDecoder.parseXML(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }

    func testParseXMLWithCustomOjpSiriNamespaces() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-ns-both")
        let locationInformation = try OJPDecoder.parseXML(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }

    func testParseMinimumRequiredLIRResponse() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-minimum-response")
        let locationInformation = try OJPDecoder.parseXML(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }

    func testParseRailBusAndUndergroundPtModes() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-lausanne")

        let locationInformation = try OJPDecoder.parseXML(xmlData).response!.serviceDelivery.delivery

        switch locationInformation {
        case .stopEvent:
            XCTFail()
        case let .locationInformation(lir):
            XCTAssert(lir.placeResults.first?.place.modes.first?.ptModeType == .rail)
            XCTAssert(lir.placeResults[1].place.modes.first?.ptModeType == .bus)
            XCTAssert(lir.placeResults[2].place.modes.first?.ptModeType == .underground)
        }
    }

    func testParseStopPlaceWithSloid() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-emmenmatt-sloid")
        let locationInformation = try OJPDecoder.parseXML(xmlData)

        switch locationInformation.response!.serviceDelivery.delivery {
        case .stopEvent:
            XCTFail()
        case let .locationInformation(lir):
            switch lir.placeResults.first!.place.placeType {
            case let .stopPlace(stopPlace):
                XCTAssert(stopPlace.stopPlaceRef == "ch:1:sloid:8206")
            case .address:
                XCTFail()
            }
        }
    }

    func testAddress() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-address")

        let locationInformation = try OJPDecoder.parseXML(xmlData).response!.serviceDelivery.delivery

        switch locationInformation {
        case .stopEvent:
            XCTFail()
        case let .locationInformation(locationInformation):
            for location in locationInformation.placeResults {
                switch location.place.placeType {
                case .stopPlace:
                    XCTFail()
                case let .address(address):
                    XCTAssert(address.houseNumber == "48")
                    XCTAssert(address.topographicPlaceName == "Le Mouret")
                    XCTAssert(address.street == "Route des Russilles")
                }
            }
        }
    }

    func testDecodingFailedError() throws {
        let invalidXmlData = "I'm not a valid xml".data(using: .utf8)!

        do {
            _ = try OJPDecoder.parseXML(invalidXmlData)
            XCTFail()
        } catch OJPSDKError.decodingFailed {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }

    func testUnexpectedHTTPStatusError() async throws {
        let mock = LoadingStrategy.mock { _ in
            try (TestHelpers.loadXML(),
                 HTTPURLResponse(
                     url: URL(string: "localhost")!,
                     statusCode: 400,
                     httpVersion: nil,
                     headerFields: [:]
                 )!)
        }
        let ojpSDK = OJP(loadingStrategy: mock)

        do {
            _ = try await ojpSDK.requestLocations(from: "bla", restrictions: .init(type: [.stop]))
            XCTFail()
        } catch let OJPSDKError.unexpectedHTTPStatus(statusCode) {
            XCTAssert(statusCode == 400)
        } catch {
            XCTFail()
        }
    }

    func testLoadingFailedError() async throws {
        let mock = LoadingStrategy.mock { _ in
            throw URLError(.badServerResponse)
        }
        do {
            let ojpSDK = OJP(loadingStrategy: mock)
            _ = try await ojpSDK.requestLocations(from: "bla", restrictions: .init(type: [.stop]))
        } catch OJPSDKError.loadingFailed {
            XCTAssert(true)
            return
        }

        XCTFail()
    }

    func testLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = locationInformationRequest.requestWith(bbox: bbox)

        let body = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest).data(using: .utf8)!

        let ojp = OJP(loadingStrategy: .http(.int))
        let (data, response) = try await ojp.loader(body)
        dump(response)

        if let xmlString = String(data: data, encoding: .utf8) {
            print(xmlString)
            let serivceDelivery = try OJPDecoder.response(data).serviceDelivery
            guard case let .locationInformation(locationInformation) = serivceDelivery.delivery else {
                XCTFail()
                return
            }
            print("places:")
            for placeResult in locationInformation.placeResults {
                print(placeResult.place.name!.text)
            }
        }

        let httpResponse = response as? HTTPURLResponse
        XCTAssertNotNil(httpResponse)
        XCTAssert(httpResponse?.statusCode == 200)
    }

    func testMockLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = locationInformationRequest.requestWith(bbox: bbox)

        let body = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest).data(using: .utf8)!

        let mock = LoadingStrategy.mock { _ in
            try (TestHelpers.loadXML(),
                 HTTPURLResponse(
                     url: URL(string: "localhost")!,
                     statusCode: 200,
                     httpVersion: nil,
                     headerFields: [:]
                 )!)
        }

        let ojp = OJP(loadingStrategy: mock)
        let (data, response) = try await ojp.loader(body)
        dump(response)

        if let xmlString = String(data: data, encoding: .utf8) {
            print(xmlString)
        }
        guard case let .locationInformation(locationInformation) = try OJPDecoder.response(data).serviceDelivery.delivery else {
            XCTFail()
            return
        }
        XCTAssert(locationInformation.placeResults.count == 26)
    }
    
    func testDifferentLocationTypes() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-location-all-types")
        let locationInformation = try OJPDecoder.parseXML(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }
}
