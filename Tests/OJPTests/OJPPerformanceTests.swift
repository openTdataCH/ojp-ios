//
//  OJPPerformanceTests.swift
//
//
//  Created by Lehnherr Reto on 04.06.2024.
//

@testable import OJP
import XCTest

final class OJPPerformanceTests: XCTestCase {
    func testTripResultPerformance_zh_stg_basic() throws {
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

    func testTripResultPerformance_be_zh_legprojection() throws {
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

    func testTripResultPerformance_be_zh_legprojection_singleResult() throws {
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
