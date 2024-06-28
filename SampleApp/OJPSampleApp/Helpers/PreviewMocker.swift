//
//  PreviewMocker.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Foundation
import OJP

class PreviewMocker {
    static let shared: PreviewMocker = .init()

    static func loadXML(xmlFilename: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml") else {
            throw NSError(domain: "Not Found", code: 1)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    static func mockLoader(xmlFilename: String = "tr-with-transfer-legs") -> LoadingStrategy {
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

    func loadTrips() async -> [OJPv2.TripResult] {
        do {
            return try await OJP(
                loadingStrategy: Self.mockLoader()
            )
            .requestTrips(
                from: .stopPlaceRef(.init(stopPlaceRef: "a",
                                          name: .init("A"))
                ),
                to: .stopPlaceRef(.init(stopPlaceRef: "b",
                                        name: .init("B"))
                ),
                params: .init()
            )
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}
