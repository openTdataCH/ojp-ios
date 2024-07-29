@testable import OJP
import XCTest

final class OjpErrorTests: XCTestCase {
    @DecoderActor func testDecodingFailedError() throws {
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
            _ = try await ojpSDK.requestPlaceResults(from: "bla", restrictions: .init(type: [.stop]))
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
            _ = try await ojpSDK.requestPlaceResults(from: "bla", restrictions: .init(type: [.stop]))
        } catch OJPSDKError.loadingFailed {
            XCTAssert(true)
            return
        }

        XCTFail()
    }
}
