//
//  OJPPerformanceTests.swift
//
//
//  Created by Lehnherr Reto on 04.06.2024.
//

@testable import OJP
import XCTest

final class OJPPerformanceTests: XCTestCase {
    @DecoderActor
    func testTripResultPerformance_zh_stg_basic() throws {
//        // Uncomment to re-create the test mock (use a proxy like charles or proxyman to get the xml)
//        Task {
//            // St. Gallen   ch:1:sloid:6302  8506302
//            // Zürich HB    ch:1:sloid:3000  8503000
//            let _ = try? await OJP(loadingStrategy: .http(.int)).requestTrips(from: .stopPointRef("8506302"), to: .stopPointRef("8503000"), params: .init(numberOfResults: .minimum(10), includeLegProjection: false))
//        }

        guard let xmlData = try? TestHelpers.loadXML(xmlFilename: "tr-perf-zh-stg-10results-wo-projection")
        else {
            return XCTFail("unexpected empty")
        }

        measure {
            do {
                let respone = try OJPDecoder.parseXML(xmlData).response!
                let delivery = respone.serviceDelivery.delivery
                switch delivery {
                case let .trip(tripDelivery):
                    XCTAssertEqual(tripDelivery.tripResults.count, 10)
                default:
                    XCTFail("Unexpeced delivery type: \(type(of: delivery))")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            XCTAssert(true)
        }
    }

    @DecoderActor
    func testTripResultPerformance_be_zh_legprojection() throws {
//        // Uncomment to re-create the test mock (use a proxy like charles or proxyman to get the xml)
//        Task {
//            // Bern         ch:1:sloid:7000  8507000
//            // Zürich HB    ch:1:sloid:3000  8503000
//            let _ = try? await OJP(loadingStrategy: .http(.int)).requestTrips(from: .stopPointRef("8507000"), to: .stopPointRef("8503000"), params: .init(numberOfResults: .minimum(20), includeLegProjection: true))
//        }

        guard let xmlData = try? TestHelpers.loadXML(xmlFilename: "tr-perf-be-zh-20results-projection")
        else {
            return XCTFail("unexpected empty")
        }

        measure {
            do {
                let respone = try OJPDecoder.parseXML(xmlData).response!
                let delivery = respone.serviceDelivery.delivery
                switch delivery {
                case let .trip(tripDelivery):
                    XCTAssertEqual(tripDelivery.tripResults.count, 20)
                default:
                    XCTFail("Unexpeced delivery type: \(type(of: delivery))")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            XCTAssert(true)
        }
    }

    @DecoderActor
    func testTripResultPerformance_be_zh_legprojection_singleResult() throws {
//        // Uncomment to re-create the test mock (use a proxy like charles or proxyman to get the xml)
//        Task {
//            // Bern         ch:1:sloid:7000  8507000
//            // Zürich HB    ch:1:sloid:3000  8503000
//            let _ = try? await OJP(loadingStrategy: .http(.int)).requestTrips(from: .stopPointRef("8507000"), to: .stopPointRef("8503000"), params: .init(numberOfResults: .minimum(1), includeLegProjection: true))
//        }

        guard let xmlData = try? TestHelpers.loadXML(xmlFilename: "tr-perf-be-zh-1result-projection")
        else {
            return XCTFail("unexpected empty")
        }

        measure {
            do {
                let respone = try OJPDecoder.parseXML(xmlData).response!
                let delivery = respone.serviceDelivery.delivery
                switch delivery {
                case let .trip(tripDelivery):
                    XCTAssertEqual(tripDelivery.tripResults.count, 1)
                default:
                    XCTFail("Unexpeced delivery type: \(type(of: delivery))")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            XCTAssert(true)
        }
    }
}
