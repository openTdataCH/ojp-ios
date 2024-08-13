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

    @DecoderActor func testParseXML() throws {
        let xmlData = try TestHelpers.loadXML()
        guard let locationInformationDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        XCTAssertTrue(true)
    }

    @DecoderActor func testParseXMLWithSiriDefaultNamespace() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-ns")
        guard let locationInformationDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        XCTAssertTrue(true)
    }

    @DecoderActor func testParseXMLWithCustomOjpSiriNamespaces() throws {
        let xmlData = try TestHelpers.loadXML(xmlFilename: "lir-be-bbox-ns-both")
        guard let locationInformationDelivery = try OJPDecoder.parseXML(xmlData).response?.serviceDelivery.delivery else {
            return XCTFail("unexpected empty")
        }
        XCTAssertTrue(true)
    }
}
