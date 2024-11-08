@testable import OJP
import XCTest

final class LoaderTests: XCTestCase {
    func testLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = OJPHelpers.LocationInformationRequest(.init(language: "de", requesterReference: ""))
            .requestWith(bbox: bbox)

        let body = try OJPHelpers.buildXMLRequest(ojpRequest: ojpRequest).data(using: .utf8)!

        let ojp = await OJP(loadingStrategy: .http(.int))
        let (data, response) = try await ojp.loader(body)

        let serivceDelivery = try await OJPDecoder.response(data).serviceDelivery
        guard case let .locationInformation(locationInformation) = serivceDelivery.delivery else {
            XCTFail()
            return
        }
        XCTAssertGreaterThan(locationInformation.placeResults.count, 0)

        let httpResponse = response as? HTTPURLResponse
        XCTAssertNotNil(httpResponse)
        XCTAssert(httpResponse?.statusCode == 200)
    }

    func testMockLoader() async throws {
        // BE/Köniz area
        let bbox = Geo.Bbox(minLongitude: 7.372097, minLatitude: 46.904860, maxLongitude: 7.479042, maxLatitude: 46.942787)
        let ojpRequest = OJPHelpers.LocationInformationRequest(.init(language: "de", requesterReference: ""))
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
        let (data, _) = try await ojp.loader(body)

        guard case let .locationInformation(locationInformation) = try await OJPDecoder.response(data).serviceDelivery.delivery else {
            XCTFail()
            return
        }
        XCTAssert(locationInformation.placeResults.count == 26)
    }
}
