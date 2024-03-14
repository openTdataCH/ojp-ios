@testable import OjpSDK
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

    func testBuildRequest() throws {
        let xmlString = try OJPHelpers.buildXMLRequest()
        XCTAssert(!xmlString.isEmpty)
    }

    func testParseXMLStrippingNamespace() throws {
        let xmlData = try TestHelpers.loadXML()
        let locationInformation = try OJPHelpers.parseXMLStrippingNamespace(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }

    func testParseXMLKeepingNamespace() throws {
        let xmlData = try TestHelpers.loadXML()
        let locationInformation = try OJPHelpers.parseXMLKeepingNamespace(xmlData)
        dump(locationInformation)
        XCTAssertTrue(true)
    }
}
