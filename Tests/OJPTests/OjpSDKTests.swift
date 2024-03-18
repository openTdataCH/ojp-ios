@testable import OJP
import XCTest

final class OjpSDKTests: XCTestCase {
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
        let ojp = OJPHelpers.LocationInformationRequest.initWithBoxCoordsWidthHeight(centerLongitude: 7.44029, centerLatitude: 46.94578, boxWidth: 1000.0)

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

    func testBuildRequest() throws {
        let xmlString = try OJPHelpers.buildXMLRequest()
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

    func testLoader() async throws {
        let body = try OJPHelpers.buildXMLRequest().data(using: .utf8)!

        let ojp = OJP(loadingStrategy: .http(.int))
        let (data, response) = try await ojp.loader(body)
        dump(response)

        if let xmlString = String(data: data, encoding: .utf8) {
            print(xmlString)
            let lir = try OJPDecoder.response(data).serviceDelivery.locationInformationDelivery
            print("places:")
            for placeResult in lir.placeResults {
                print(placeResult.place.name.text)
            }
        }

        let httpResponse = response as? HTTPURLResponse
        XCTAssertNotNil(httpResponse)
        XCTAssert(httpResponse?.statusCode == 200)
    }

    func testMockLoader() async throws {
        let body = try OJPHelpers.buildXMLRequest().data(using: .utf8)!

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
        let lir = try OJPDecoder.response(data).serviceDelivery.locationInformationDelivery
        XCTAssert(lir.placeResults.count == 26)
    }

    func testFetchNearbyStations() async throws {
        let ojpSdk = OJP(loadingStrategy: .http(.int))

        let nearbyStations = try await ojpSdk.nearbyStations(from: (long: 7.452178, lat: 46.948474))

        XCTAssert(nearbyStations.first!.place.name.text == "Rathaus")
    }
}
