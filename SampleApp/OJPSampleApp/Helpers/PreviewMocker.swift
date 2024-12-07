//
//  PreviewMocker.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Foundation
import OJP

actor PreviewMocker {
    static let shared: PreviewMocker = .init()

    static func loadXML(xmlFilename: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml") else {
            throw NSError(domain: "Not Found", code: 1)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    static func mockLoader(xmlFilename: String) -> LoadingStrategy {
        .mock { _ in
            do {
                let data = try loadXML(xmlFilename: xmlFilename)
                print("success!")
                return (data, mockedResponse(statusCode: 200))
            } catch {
                return (Data(), mockedResponse(statusCode: 500))
            }
        }
    }

    private static func mockedResponse(statusCode: Int) -> URLResponse {
        HTTPURLResponse(url: URL(string: "https://localhost")!, statusCode: statusCode, httpVersion: "1.0", headerFields: [:])!
    }

    func loadTrips(xmlFileName: String = "tr-with-transfer-legs") async throws -> OJPv2.TripDelivery {
        try await OJP(
            loadingStrategy: Self.mockLoader(xmlFilename: xmlFileName)
        )
        .requestTrips(
            from: .stopPlaceRef(
                .init(
                    stopPlaceRef: "a",
                    name: .init("A")
                )
            ),
            to: .stopPlaceRef(
                .init(
                    stopPlaceRef: "b",
                    name: .init("B")
                )
            ),
            params: .init()
        )
    }

    func loadLoadTripInfo(xmlFileName: String = "tir") async throws -> OJPv2.TripInfoDelivery {
        try await OJP(
            loadingStrategy: Self.mockLoader(xmlFilename: xmlFileName)
        )
        .requestTripInfo(journeyRef: "", operatingDayRef: "", params: .init())
    }

    func loadStopEvents(xmlFileName: String = "ser-two-results") async throws -> OJPv2.StopEventDelivery {
        try await OJP(
            loadingStrategy: Self.mockLoader(xmlFilename: xmlFileName)
        ).requestStopEvent(
            location: .init(
                placeRef: .stopPlaceRef(
                    .init(stopPlaceRef: "", name: .init(""))
                ),
                depArrTime: nil
            ),
            params: nil
        )
    }
}
