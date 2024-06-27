//
//  TripRequestView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import SwiftUI
import OJP
struct TripRequestView: View {

    var results: [OJPv2.TripResult] = []

    var body: some View {

        VStack {
            Text("Hai")
            List(results) { tripResult in
                Text(tripResult.id)
            }
        }
    }
}

struct AsyncView<Content: View, S>: View {
    @ViewBuilder let content: (S) -> Content
    let task: () async -> S

    @State var state: S

    var body: some View {
        content(state)
            .task {
                print("hai")
                state = await task()
//
            }
    }
}

class Mocked {

    static let shared: Mocked = Mocked()

    static func loadXML(xmlFilename: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml") else {
            throw NSError(domain: "Not Found", code: 1)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    static func mockLoader(xmlFilename: String = "tr-perf-be-zh-20results-projection") -> LoadingStrategy {
        .mock { _ in
            do {
                let data = try loadXML(xmlFilename: xmlFilename)
                return (data, URLResponse())
            } catch {
                return (Data(), URLResponse())
            }
        }
    }

    func loadTrips() async -> [OJPv2.TripResult] {
        do {
            return try await OJP(loadingStrategy: Self.mockLoader()).requestTrips(from: .stopPlaceRef(""), to: .stopPlaceRef(""), params: .init())
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}


#Preview {
    AsyncView(
        content: { tripResults in
            TripRequestView(results: tripResults)
        }, task: { await Mocked.shared.loadTrips() },
        state: []
    )
}

