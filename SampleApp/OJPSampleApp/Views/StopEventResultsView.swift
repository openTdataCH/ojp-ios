//
//  StopEventResultsView.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.11.2024.
//

import OJP
import SwiftUI

struct StopEventResultsView: View {
    let ojp: OJP

    @State var origin: OJPv2.PlaceResult?
    @State var stopEventResults: [String: [OJPv2.StopEventResult]]?
    @State var mode: StopEventMode = .departure

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                InlineLocationSerachView(
                    ojp: ojp,
                    textLabel: "Station",
                    selectedPlace: $origin
                )
                Picker("Mode", selection: $mode) {
                    ForEach([StopEventMode.departure, .arrival], id: \.self) {
                        Text("\($0.rawValue)").tag($0)
                    }
                }
                .frame(width: 150)
            }
            if let results = stopEventResults,
               let stops = stopEventResults?.keys.map({ String($0) })
            {
                List(stops, id: \.self) { title in
                    Section(title) {
                        ForEach(results[title]!) { stopEvent in
                            StopEventView(
                                stopEvent: stopEvent.stopEvent,
                                mode: mode
                            )
                        }
                    }
                }
            }
            Spacer()
        }
        .onChange(of: origin) {
            Task {
                try await loadStopEvents()
            }
        }
        .onChange(of: mode) {
            Task {
                try await loadStopEvents()
            }
        }
    }

    func loadStopEvents() async throws {
        guard let origin else { return }
        stopEventResults = nil
        let stopEventDelivery = try await ojp.requestStopEvent(
            location: .init(
                placeRef: origin.placeRef,
                depArrTime: nil
            ),
            params: .init(
                stopEventType: mode.ojpType,
                numberOfResults: nil
            )
        )
        stopEventResults = stopEventDelivery.stopEventsGroupedByStation
    }
}

extension OJPv2.PlaceResult: @retroactive Equatable {
    public static func == (lhs: OJPv2.PlaceResult, rhs: OJPv2.PlaceResult) -> Bool {
        lhs.placeRef == rhs.placeRef
    }
}

extension OJPv2.StopEventResult: @retroactive Identifiable {
    public var id: String {
        // 😱 https://github.com/openTdataCH/ojp-sdk/issues/173
        stopEvent.service.journeyRef
    }
}

#Preview {
    StopEventResultsView(ojp: OJP(loadingStrategy: .http(.int)))
}
