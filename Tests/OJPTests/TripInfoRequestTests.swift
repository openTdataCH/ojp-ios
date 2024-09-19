@testable import OJP
import XCTest

final class TripInfoRequestTests: XCTestCase {
    func testNormalTripInfoRequest() async throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "tir")
        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        guard case let .tripInfo(tripInfoDelivery) = tripDelivery else { return XCTFail() }
        let responseContext = try XCTUnwrap(tripInfoDelivery.tripInfoResponseContext)
        XCTAssertEqual(responseContext.places.count, 6)

        XCTAssertEqual(tripInfoDelivery.tripInfoResult?.previousCalls.count, 4)
        XCTAssertEqual(tripInfoDelivery.tripInfoResult?.onwardCalls.count, 8)
    }
}
