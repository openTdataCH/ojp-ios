@testable import OJP
import XCTest

final class LoaderTests: XCTestCase {
    func testLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = OJPHelpers.LocationInformationRequest(requesterReference: "")
            .requestWith(bbox: bbox)

        let body = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest).data(using: .utf8)!

        let ojp = await OJP(loadingStrategy: .http(.int))
        let (data, response) = try await ojp.loader(body)
        dump(response)

        if let xmlString = String(data: data, encoding: .utf8) {
            print(xmlString)
            let serivceDelivery = try await OJPDecoder.response(data).serviceDelivery
            guard case let .locationInformation(locationInformation) = serivceDelivery.delivery else {
                XCTFail()
                return
            }
            print("places:")
            for placeResult in locationInformation.placeResults {
                print(placeResult.place.name.text)
            }
        }

        let httpResponse = response as? HTTPURLResponse
        XCTAssertNotNil(httpResponse)
        XCTAssert(httpResponse?.statusCode == 200)
    }

    func testMockLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = OJPHelpers.LocationInformationRequest(requesterReference: "")
            .requestWith(bbox: bbox)

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
        guard case let .locationInformation(locationInformation) = try await OJPDecoder.response(data).serviceDelivery.delivery else {
            XCTFail()
            return
        }
        XCTAssert(locationInformation.placeResults.count == 26)
    }
}
