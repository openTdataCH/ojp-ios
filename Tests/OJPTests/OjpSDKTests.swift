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

    func testLoader() async throws {
        let body = try OJPHelpers.buildXMLRequest().data(using: .utf8)!

        let ojp = OJP(loadingStrategy: .http(.test))
        let (data, response) = try await ojp.loader(body)
        dump(response)

        if let xmlString = String(data: data, encoding: .utf8) {
            print(xmlString)
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
        let lir = try OJPHelpers.parseXMLStrippingNamespace(data)
        XCTAssert(lir.placeResults.count == 26)
    }
}
