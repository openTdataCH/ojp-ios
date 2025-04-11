@testable import OJP
import XCTest

final class TripRefineRequestTests: XCTestCase {
    func testNormalTripRefineRequest() async throws {
        // Note: trr-response-bern-stmoritz.xml is currently manually made:
        // - TripResult in the TRR-Response is replaced by the "full" TripResult from the initial TripRequest
        // - TripResponseContext in TRR Response is replaced by the fool TripResponseContext from TripRequest
        let xmlData = try TestHelpers.loadXML(xmlFilename: "trr-response-bern-stmoritz")
        guard let tripDelivery = try await OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }

        guard case let .tripRefinement(tripRefineDelivery) = tripDelivery else { return XCTFail() }
        let responseContext = try XCTUnwrap(tripRefineDelivery.tripResponseContext)
        XCTAssertEqual(responseContext.places.count, 123)

        XCTAssertEqual(tripRefineDelivery.tripResults.count, 1)
        XCTAssertEqual(tripRefineDelivery.tripResults.first?.trip?.legs.count, 3)
    }
}
